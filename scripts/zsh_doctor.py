from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path


@dataclass
class Check:
    id: str
    name: str
    status: str
    details: str
    hint: str = ""


def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def run(command: list[str], cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=cwd,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )


def broken_site_function_links() -> list[str]:
    roots = [
        Path("/opt/homebrew/share/zsh/site-functions"),
        Path("/usr/local/share/zsh/site-functions"),
    ]
    broken: list[str] = []
    for root in roots:
        if not root.is_dir():
            continue
        for path in root.iterdir():
            if path.is_symlink() and not path.exists():
                broken.append(str(path))
    return broken


def duplicate_items(items: list[str]) -> list[str]:
    seen: set[str] = set()
    duplicates: list[str] = []
    for item in items:
        if item in seen and item not in duplicates:
            duplicates.append(item)
        seen.add(item)
    return duplicates


def shell_probe() -> tuple[dict, str, int]:
    script = (
        "print -r -- ZSH_DOCTOR_JSON_START;"
        "python3 - <<'PY'\n"
        "import json, os\n"
        "print(json.dumps({\n"
        "  'path': os.environ.get('PATH', '').split(':'),\n"
        "  'zsh': os.environ.get('ZSH', ''),\n"
        "  'theme': os.environ.get('ZSH_THEME', ''),\n"
        "}))\n"
        "PY\n"
        "print -r -- ZSH_DOCTOR_JSON_END;"
        "print -rl -- $fpath > /tmp/zsh-doctor-fpath.$$"
    )
    result = run(["zsh", "-lic", script])
    output = (result.stdout or "") + (result.stderr or "")
    data: dict = {}
    if "ZSH_DOCTOR_JSON_START" in output and "ZSH_DOCTOR_JSON_END" in output:
        between = output.split("ZSH_DOCTOR_JSON_START", 1)[1].split("ZSH_DOCTOR_JSON_END", 1)[0]
        for line in between.splitlines():
            line = line.strip()
            if line.startswith("{") and line.endswith("}"):
                data = json.loads(line)
                break
    return data, output, result.returncode


def collect_checks() -> list[Check]:
    root = repo_root()
    checks: list[Check] = []

    checks.append(
        Check(
            "zsh_binary",
            "zsh executable",
            "pass" if shutil.which("zsh") else "fail",
            shutil.which("zsh") or "missing",
            "Install zsh before applying this configuration.",
        )
    )

    checks.append(
        Check(
            "oh_my_zsh",
            "oh-my-zsh directory",
            "pass" if (Path.home() / ".oh-my-zsh").is_dir() else "fail",
            str(Path.home() / ".oh-my-zsh"),
            "Install oh-my-zsh before running setup.",
        )
    )

    for relative in [".zshrc", "setup_spaceship.sh", "spaceship/spaceship.zsh"]:
        result = run(["zsh", "-n", str(root / relative)], cwd=root)
        checks.append(
            Check(
                f"syntax_{relative.replace('/', '_')}",
                f"Syntax check {relative}",
                "pass" if result.returncode == 0 else "fail",
                (result.stderr or result.stdout).strip() or "ok",
            )
        )

    login_data, login_output, login_code = shell_probe()
    checks.append(
        Check(
            "login_shell",
            "Login shell starts without errors",
            "pass" if login_code == 0 else "fail",
            "ok" if login_code == 0 else (login_output.strip() or "failed"),
        )
    )

    broken = broken_site_function_links()
    checks.append(
        Check(
            "broken_completions",
            "Broken zsh completion symlinks",
            "pass" if not broken else "fail",
            ", ".join(broken) if broken else "none",
            "Remove broken symlinks and rebuild ~/.zcompdump.",
        )
    )

    path_items = login_data.get("path", []) if isinstance(login_data, dict) else []
    path_dupes = duplicate_items(path_items)
    checks.append(
        Check(
            "path_duplicates",
            "PATH duplicate entries",
            "pass" if not path_dupes else "warn",
            ", ".join(path_dupes) if path_dupes else "none",
            "Use typeset -U path and keep local PATH changes in ~/.config/zsh/local.zsh.",
        )
    )

    local_file = Path.home() / ".config/zsh/local.zsh"
    checks.append(
        Check(
            "local_override",
            "Machine-local override file",
            "pass" if local_file.exists() else "warn",
            str(local_file),
            "Create this file for pyenv, private tools, and host-specific PATH entries.",
        )
    )

    installed = Path.home() / ".zshrc"
    repo_zshrc = root / ".zshrc"
    if installed.exists():
        same = installed.read_text(encoding="utf-8", errors="replace") == repo_zshrc.read_text(
            encoding="utf-8", errors="replace"
        )
        checks.append(
            Check(
                "zshrc_drift",
                "~/.zshrc matches repository template",
                "pass" if same else "warn",
                "matches" if same else "differs",
                "Run ./setup_spaceship.sh --apply after moving machine-local settings into ~/.config/zsh/local.zsh.",
            )
        )

    return checks


def main() -> int:
    parser = argparse.ArgumentParser(description="Diagnose local zsh_config installation health.")
    parser.add_argument("--json", action="store_true", help="Emit JSON.")
    args = parser.parse_args()

    checks = collect_checks()
    if args.json:
        print(json.dumps({"checks": [asdict(check) for check in checks]}, indent=2, ensure_ascii=False))
    else:
        print("zsh_config Doctor")
        for check in checks:
            marker = {"pass": "PASS", "warn": "WARN", "fail": "FAIL"}.get(check.status, check.status.upper())
            print(f"[{marker}] {check.name}: {check.details}")
            if check.status != "pass" and check.hint:
                print(f"       Hint: {check.hint}")

    return 1 if any(check.status == "fail" for check in checks) else 0


if __name__ == "__main__":
    raise SystemExit(main())
