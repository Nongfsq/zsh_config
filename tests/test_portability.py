"""Regression checks use synthetic private values and temporary home directories."""
from __future__ import annotations

import copy
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
import iterm2_profiles as profiles


class ProfileTests(unittest.TestCase):
    def test_shared_backup_is_portable_and_stable(self):
        document = json.loads(profiles.DEFAULT_BACKUP.read_text())
        profiles.check(document)
        self.assertEqual(profiles.sanitize(document), document)
        self.assertEqual(len(document["Profiles"]), 2)
        self.assertEqual(len({p["Guid"] for p in document["Profiles"]}), 2)
        for profile in document["Profiles"]:
            self.assertEqual(len(profile["Keyboard Map"]), 40)
            self.assertEqual(profile["Working Directory"], "")
            self.assertEqual(profile["Custom Directory"], "No")

    def test_private_and_unknown_nested_fields_cannot_survive_export(self):
        private = "PRIVATE_FIXTURE_SENTINEL"
        profile = {
            "Name": private, "Guid": private, "Description": private,
            "Working Directory": str(Path("/") / "Users" / private),
            "Custom Directory": "Yes", "Custom Command": "Yes", "Command": private,
            "Initial Text": private, "Background Image Location": private,
            "Badge Text": private, "Tags": [private], "Bound Hosts": [private],
            "Triggers": [{"regex": private, "parameter": private}],
            "Environment Variables": {"ACCESS_TOKEN": private},
            "Future Setting": {"nested": [private]},
            "Normal Font": "Monaco 18", "Rows": 25, "Use Bold Font": True,
            "Foreground Color": {
                "Red Component": 0.5, "Green Component": 0.6,
                "Blue Component": 0.7, "Unknown Metadata": private,
            },
            "Keyboard Map": {
                "0xf700-0x260000": {"Action": 10, "Text": "[1;6A", "Label": private},
                "0x32-0x40000": {"Action": 11, "Text": "0x00"},
                "0x33-0x40000": {"Action": 12, "Text": private},
                "0x34-0x40000": {"Action": 11, "Text": "0x73 0x73 0x68"},
            },
        }
        original = copy.deepcopy(profile)
        output = profiles.sanitize({"Profiles": [profile], "Metadata": private})
        self.assertNotIn(private, json.dumps(output))
        self.assertEqual(profile, original)
        saved = output["Profiles"][0]
        self.assertEqual(saved["Normal Font"], "Monaco 18")
        self.assertEqual(saved["Rows"], 25)
        self.assertEqual(len(saved["Keyboard Map"]), 2)
        self.assertEqual(saved["Command"], "")
        profiles.check(output)

    def test_unreviewed_visual_text_is_rejected(self):
        for field, value in [
            ("Normal Font", "UNREVIEWED_FONT 18"),
            ("Rows", "PRIVATE_FIXTURE_SENTINEL"),
            ("Use Bold Font", "true"),
            ("Transparency", float("nan")),
            ("Foreground Color", {"Red Component": "private"}),
        ]:
            with self.subTest(field=field), self.assertRaises(ValueError):
                profiles.sanitize({"Profiles": [{field: value}]})

    def test_checker_rejects_identity_and_unknown_settings(self):
        for field, value in [
            ("Name", "PRIVATE_FIXTURE_SENTINEL"),
            ("Command", "echo private"),
            ("Future Setting", {"token": "private"}),
        ]:
            document = profiles.sanitize({"Profiles": [{}]})
            document["Profiles"][0][field] = value
            with self.subTest(field=field), self.assertRaises(ValueError):
                profiles.check(document)

    def test_cli_preserves_source_and_requires_explicit_overwrite(self):
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "source.json"
            output = Path(temporary) / "output.json"
            raw = json.dumps({"Profiles": [{"Name": "PRIVATE_FIXTURE_SENTINEL"}]})
            source.write_text(raw)
            command = [sys.executable, str(ROOT / "scripts/iterm2_profiles.py"), "sanitize", str(source)]
            result = subprocess.run(command + [str(output)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            saved = output.read_bytes()
            result = subprocess.run(command + [str(output)], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(output.read_bytes(), saved)
            result = subprocess.run(command + [str(source), "--force"], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(source.read_text(), raw)
            source.write_text('{"Profiles": [{"Normal Font": "unreviewed"}]}')
            result = subprocess.run(command + [str(output), "--force"], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(output.read_bytes(), saved)


@unittest.skipUnless(shutil.which("zsh") and shutil.which("bash"), "Zsh and Bash required")
class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="zsh config test ")
        self.addCleanup(self.temporary.cleanup)
        self.base = Path(self.temporary.name)
        self.user_dir = self.base / "home"
        self.user_dir.mkdir()
        self.zsh_dir = self.base / "custom oh my zsh"
        self.zsh_dir.mkdir()
        (self.zsh_dir / "oh-my-zsh.sh").write_text('export FIXTURE_OMZ_LOADED="$ZSH"\n')
        self.custom_dir = self.base / "custom theme directory"
        self.theme_dir = self.custom_dir / "themes/spaceship-prompt"
        self.theme_dir.mkdir(parents=True)
        (self.theme_dir / "spaceship.zsh-theme").write_text("# fixture theme\n")
        self.theme_link = self.custom_dir / "themes/spaceship.zsh-theme"
        self.startup_dir = self.base / "zsh startup directory"
        self.startup_dir.mkdir()
        # Minimal child environment: never source the developer's real shell.
        self.environment = {
            "HOME": str(self.user_dir), "ZSH": str(self.zsh_dir),
            "ZSH_CUSTOM": str(self.custom_dir), "ZDOTDIR": str(self.startup_dir),
            "PATH": os.environ["PATH"], "TERM": "xterm-256color",
        }

    def setup_command(self, *arguments):
        return subprocess.run(
            ["bash", str(ROOT / "setup_spaceship.sh"), *arguments],
            env=self.environment, capture_output=True, text=True, timeout=20,
        )

    def test_dry_run_changes_nothing(self):
        before = sorted(str(p.relative_to(self.base)) for p in self.base.rglob("*"))
        result = self.setup_command("--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        after = sorted(str(p.relative_to(self.base)) for p in self.base.rglob("*"))
        self.assertEqual(before, after)
        self.assertIn("Preview complete", result.stdout)

    def test_apply_backs_up_files_preserves_link_targets_and_is_repeatable(self):
        external = self.base / "existing dotfile"
        external.write_text("# existing external configuration\n")
        target = self.startup_dir / ".zshrc"
        target.symlink_to(external)
        config = self.user_dir / ".config/spaceship/spaceship.zsh"
        config.parent.mkdir(parents=True)
        config.write_text("# previous prompt\n")
        overlay = self.user_dir / ".config/zsh/local.zsh"
        overlay.parent.mkdir(parents=True)
        overlay.write_text("export FIXTURE_OVERLAY_LOADED=yes\n")
        self.theme_link.write_text("# previous theme\n")

        result = self.setup_command("--apply")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(target.is_symlink())
        self.assertEqual(target.read_bytes(), (ROOT / ".zshrc").read_bytes())
        self.assertEqual(external.read_text(), "# existing external configuration\n")
        self.assertEqual(config.read_bytes(), (ROOT / "spaceship/spaceship.zsh").read_bytes())
        self.assertEqual(overlay.read_text(), "export FIXTURE_OVERLAY_LOADED=yes\n")
        self.assertEqual(self.theme_link.resolve(), (self.theme_dir / "spaceship.zsh-theme").resolve())
        backups = list((self.user_dir / ".zsh_config_backup").iterdir())
        self.assertEqual(len(backups), 1)
        self.assertTrue((backups[0] / ".zshrc").is_symlink())
        self.assertEqual((backups[0] / "spaceship.zsh").read_text(), "# previous prompt\n")
        self.assertEqual((backups[0] / "spaceship.zsh-theme").read_text(), "# previous theme\n")
        self.assertEqual(backups[0].stat().st_mode & 0o777, 0o700)
        self.assertFalse((self.user_dir / ".zshrc").exists())

        result = self.setup_command("--apply")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(list((self.user_dir / ".zsh_config_backup").iterdir()), backups)
        probe = subprocess.run(
            ["zsh", "-dfc", 'source "$ZDOTDIR/.zshrc"; print -r -- "$FIXTURE_OMZ_LOADED" "$FIXTURE_OVERLAY_LOADED"'],
            env=self.environment, capture_output=True, text=True, timeout=20,
        )
        self.assertEqual(probe.returncode, 0, probe.stderr)
        self.assertIn(str(self.zsh_dir), probe.stdout)
        self.assertIn("yes", probe.stdout)

    def test_new_overlay_is_private(self):
        result = self.setup_command("--apply")
        self.assertEqual(result.returncode, 0, result.stderr)
        overlay = self.user_dir / ".config/zsh/local.zsh"
        self.assertEqual(overlay.stat().st_mode & 0o777, 0o600)

    def test_directory_conflict_stops_before_installation(self):
        (self.startup_dir / ".zshrc").mkdir()
        result = self.setup_command("--apply")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.theme_link.exists())
        self.assertFalse((self.user_dir / ".config").exists())


if __name__ == "__main__":
    unittest.main()
