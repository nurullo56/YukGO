#!/usr/bin/env python3

import os
import argparse
from pathlib import Path

# ==========================================
# Advanced Linux tree clone
# ==========================================

DEFAULT_IGNORE = {
    "__pycache__",
    ".git",
    ".idea",
    ".vscode",
    ".dart_tool",
    "build",
    ".plugin_symlinks",
    "ephemeral",
    ".DS_Store",
}

FOLDER_ICON = "📁"
FILE_ICON = "📄"


class Tree:
    def __init__(
        self,
        root=".",
        show_hidden=False,
        dirs_only=False,
        max_depth=None,
        ignore=None,
    ):
        self.root = Path(root)
        self.show_hidden = show_hidden
        self.dirs_only = dirs_only
        self.max_depth = max_depth
        self.ignore = ignore or set()

        self.total_dirs = 0
        self.total_files = 0

    def run(self):
        print(f"{FOLDER_ICON} {self.root.resolve().name}")

        self._walk(self.root)

        print()
        print(
            f"📦 {self.total_dirs} directories, "
            f"{self.total_files} files"
        )

    def should_ignore(self, path: Path):
        if path.name in self.ignore:
            return True

        if not self.show_hidden and path.name.startswith("."):
            return True

        return False

    def _walk(self, path, prefix="", depth=0):
        if self.max_depth is not None and depth >= self.max_depth:
            return

        try:
            entries = sorted(
                [
                    e for e in path.iterdir()
                    if not self.should_ignore(e)
                ],
                key=lambda e: (not e.is_dir(), e.name.lower())
            )

        except PermissionError:
            print(prefix + "└── ❌ Permission denied")
            return

        if self.dirs_only:
            entries = [e for e in entries if e.is_dir()]

        for index, entry in enumerate(entries):
            is_last = index == len(entries) - 1

            connector = "└── " if is_last else "├── "

            icon = FOLDER_ICON if entry.is_dir() else FILE_ICON

            print(
                f"{prefix}{connector}{icon} {entry.name}"
            )

            if entry.is_dir():
                self.total_dirs += 1

                extension = "    " if is_last else "│   "

                self._walk(
                    entry,
                    prefix + extension,
                    depth + 1
                )

            else:
                self.total_files += 1


def main():
    parser = argparse.ArgumentParser(
        description="Professional Linux tree clone"
    )

    parser.add_argument(
        "path",
        nargs="?",
        default=".",
        help="Directory path"
    )

    parser.add_argument(
        "-a",
        "--all",
        action="store_true",
        help="Show hidden files"
    )

    parser.add_argument(
        "-d",
        "--dirs-only",
        action="store_true",
        help="Show only directories"
    )

    parser.add_argument(
        "-L",
        "--level",
        type=int,
        help="Max depth level"
    )

    parser.add_argument(
        "-i",
        "--ignore",
        nargs="*",
        default=[],
        help="Extra ignore folders/files"
    )

    args = parser.parse_args()

    ignore_set = DEFAULT_IGNORE.union(set(args.ignore))

    tree = Tree(
        root=args.path,
        show_hidden=args.all,
        dirs_only=args.dirs_only,
        max_depth=args.level,
        ignore=ignore_set,
    )

    tree.run()


if __name__ == "__main__":
    main()