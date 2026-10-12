#!/usr/bin/env python3
"""Write the settings declared in Nix into the shell's settings.json.

Run before the shell starts: the shell keeps its settings in memory and writes
them back, so a change made while it runs would be lost. Declared keys win;
every other key stays as the shell wrote it. Without a file yet, the declared
keys alone are written and the shell fills in its defaults around them.
"""

import json
import os
import sys


def main():
    declared_path, target = sys.argv[1:]
    with open(declared_path, encoding="utf-8") as handle:
        declared = json.load(handle)

    try:
        with open(target, encoding="utf-8") as handle:
            current = json.load(handle)
    except FileNotFoundError:
        current = {}
    except (OSError, ValueError):
        return
    if not isinstance(current, dict):
        return
    if os.path.exists(target) and all(current.get(key) == value for key, value in declared.items()):
        return

    current.update(declared)
    os.makedirs(os.path.dirname(target), exist_ok=True)
    with open(target, "w", encoding="utf-8") as handle:
        json.dump(current, handle, indent=4)


if __name__ == "__main__":
    main()
