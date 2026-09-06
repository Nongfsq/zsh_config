#!/usr/bin/env python3
"""Keep a conservative, directly importable iTerm2 backup without local identity."""
from __future__ import annotations

import argparse
import json
import math
import re
import sys
import uuid
from pathlib import Path

DEFAULT_BACKUP = Path(__file__).resolve().parent.parent / "iterm2/profiles.json"
BOOL_FIELDS = set("""ASCII Anti Aliased|ASCII Ligatures|Ambiguous Double Width|BM Growl|
Blink Allowed|Blinking Cursor|Blur|Brighten Bold Text|Close Sessions On End|
Disable Window Resizing|Flashing Bell|Hide After Opening|Mouse Reporting|
Non-ASCII Anti Aliased|Non-ASCII Ligatures|Only The Default BG Color Uses Transparency|
Prompt Before Closing 2|Right Option Key Changeable|Show Mark Indicators|Silence Bell|
Sync Title|Unlimited Scrollback|Use Bold Font|Use Bright Bold|Use Italic Font|
Use Non-ASCII Font|Visual Bell""".replace("\n", "").split("|"))
NUMBER_FIELDS = set("""Background Image Mode|Badge Right Margin|Badge Top Margin|
Character Encoding|Columns|Cursor Type|Horizontal Spacing|Icon|Option Key Sends|
Right Option Key Sends|Rows|Scrollback Lines|Thin Strokes|Transparency|
Unicode Normalization|Unicode Version|Vertical Spacing|Window Type|
Badge Max Height|Badge Max Width|Blur Radius""".replace("\n", "").split("|"))
COLOR_FIELDS = {f"Ansi {i} Color" for i in range(16)} | {
    "Background Color", "Bold Color", "Cursor Color", "Cursor Text Color",
    "Foreground Color", "Selected Text Color", "Selection Color",
}
# Font labels are free text in exports. Keep only reviewed font families; extend
# this set after reviewing a new font instead of accepting arbitrary strings.
FONT_FAMILIES = {"Monaco", "MononokiNF-Regular", "MononokiNF-Bold"}
FONT_FIELDS = {"Normal Font", "Non Ascii Font", "Badge Font"}
FIXED_FIELDS = {
    "Custom Directory": "No",  # iTerm2's Home Directory mode resolves the user.
    "Working Directory": "",
    "Custom Command": "No",  # Use the importing user's login shell.
    "Command": "",
    "Initial Text": "",
    "Send Code When Idle": False,
    "Idle Code": 0,
    "Default Bookmark": "No",
    "Description": "",
    "Background Image Location": "",
    "Badge Text": "",
    "Shortcut": "",
    "Tags": [],
    "Bound Hosts": [],
    "Triggers": [],
    "Jobs to Ignore": ["rlogin", "ssh", "slogin", "telnet"],
    "Terminal Type": "xterm-256color",
    "Screen": -1,
}


def profiles_in(document: object) -> list[dict]:
    if not isinstance(document, dict) or not isinstance(document.get("Profiles"), list):
        raise ValueError("Expected an iTerm2 JSON object with a Profiles array.")
    profiles = document["Profiles"]
    if not profiles or not all(isinstance(p, dict) for p in profiles):
        raise ValueError("Profiles must contain at least one profile object.")
    return profiles


def finite_number(value: object) -> bool:
    return type(value) in (int, float) and math.isfinite(value)


def color(value: object) -> dict:
    if not isinstance(value, dict):
        raise ValueError("Expected a color object.")
    components = {"Red Component", "Green Component", "Blue Component"}
    if not components <= value.keys():
        raise ValueError("Color is missing RGB components.")
    result = {}
    for key in components | {"Alpha Component"}:
        if key in value:
            if not finite_number(value[key]) or not 0 <= value[key] <= 1:
                raise ValueError("Color components must be numbers between 0 and 1.")
            result[key] = value[key]
    if "Color Space" in value:
        if value["Color Space"] not in ("sRGB", "Calibrated", "P3"):
            raise ValueError("Unreviewed color space.")
        result["Color Space"] = value["Color Space"]
    return result


def font(value: object, sized: bool) -> str:
    if not isinstance(value, str):
        raise ValueError("Expected a font string.")
    family = value
    if sized:
        family, separator, size = value.rpartition(" ")
        if not separator or not re.fullmatch(r"\d+(?:\.\d+)?", size) or not 0 < float(size) <= 200:
            raise ValueError("Expected a font family followed by a size from 0 to 200.")
    if family not in FONT_FAMILIES:
        raise ValueError("Unreviewed font family; review and extend FONT_FAMILIES before exporting.")
    return value


def keyboard_map(value: object) -> dict:
    if not isinstance(value, dict):
        raise ValueError("Expected a keyboard map object.")
    result = {}
    for key, binding in value.items():
        if not re.fullmatch(r"0x[0-9a-f]+-0x[0-9a-f]+", key) or not isinstance(binding, dict):
            continue
        action, text = binding.get("Action"), binding.get("Text")
        if type(action) is not int or not isinstance(text, str):
            continue
        # Preserve terminal control sequences, never text macros, commands, or
        # profile references. Even Send Hex Codes is restricted to control keys.
        if (action == 10 and re.fullmatch(r"\[[0-9;]*[A-Za-z~]", text)) or (
            action == 11 and re.fullmatch(r"0x(?:[01][0-9a-f]|7f)|0x1b 0x1b 0x5b 0x4[1-4]", text)
        ):
            result[key] = {"Action": action, "Text": text}
    return result


def sanitize(document: object) -> dict:
    output = []
    for index, profile in enumerate(profiles_in(document), 1):
        result = {}
        for key, value in profile.items():
            if key in BOOL_FIELDS:
                if type(value) is not bool:
                    raise ValueError("Expected a boolean visual preference.")
                result[key] = value
            elif key in NUMBER_FIELDS:
                if not finite_number(value):
                    raise ValueError("Expected a finite numeric visual preference.")
                result[key] = value
            elif key in COLOR_FIELDS:
                result[key] = color(value)
            elif key in FONT_FIELDS:
                result[key] = font(value, sized=key != "Badge Font")
            elif key == "Keyboard Map":
                result[key] = keyboard_map(value)
            # Unknown attributes are omitted, including nested local metadata.
        result.update(FIXED_FIELDS)
        result["Name"] = "Zsh Config" if index == 1 else f"Zsh Config {index}"
        # Stable project identifiers, unrelated to names or GUIDs in the export.
        result["Guid"] = str(uuid.uuid5(uuid.NAMESPACE_URL, f"urn:zsh-config:iterm2:profile:{index}"))
        output.append(result)
    return {"Profiles": output}


def check(document: object) -> None:
    expected = sanitize(document)
    if document != expected:
        raise ValueError("Profile contains unapproved fields, identity, or startup settings; sanitize it first.")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    verify = commands.add_parser("check", help="Check the shared backup's portability contract.")
    verify.add_argument("path", nargs="?", type=Path, default=DEFAULT_BACKUP)
    export = commands.add_parser("sanitize", help="Save only reviewed portable preferences.")
    export.add_argument("source", type=Path)
    export.add_argument("output", type=Path)
    export.add_argument("--force", action="store_true", help="Replace an existing output file.")
    args = parser.parse_args()
    try:
        if args.command == "check":
            check(json.loads(args.path.read_text(encoding="utf-8")))
            print("PASS: iTerm2 profiles satisfy the portable backup contract.")
        else:
            if args.source.resolve() == args.output.resolve():
                raise ValueError("Source and output must be different files.")
            if args.output.is_symlink():
                raise ValueError("Output must not be a symbolic link.")
            result = sanitize(json.loads(args.source.read_text(encoding="utf-8")))
            data = json.dumps(result, indent=2, ensure_ascii=False, sort_keys=True) + "\n"
            with args.output.open("w" if args.force else "x", encoding="utf-8") as stream:
                stream.write(data)
            print(f"Saved {len(result['Profiles'])} portable profiles. Review the diff before committing.")
            print("Kept reviewed visual preferences and control keys; reset identity/startup fields and omitted all other attributes.")
    except (OSError, ValueError) as error:
        # JSON errors and validation failures do not echo source values.
        print(f"Error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
