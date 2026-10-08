"""Run: python3 tests/helix_formatter.py /path/to/deltia/backend"""

import subprocess
import sys
import tomllib
from pathlib import Path

root = Path(sys.argv[1]).resolve()
config = tomllib.loads((root / ".helix/languages.toml").read_text())
source = ('import { z } from "zod";\n'
          'import { useState, useEffect } from "react";\n'
          'export const values={z,useState,useEffect};\n')
expected = ('import { useEffect, useState } from "react";\n'
            'import { z } from "zod";\n'
            'export const values = { z, useState, useEffect };\n')

for language in config["language"]:
    if language["name"] not in {"javascript", "jsx", "typescript", "tsx"}:
        continue
    formatter = language["formatter"]
    for filename in ("main.tsx", "src/main.tsx", "frontend/src/main.tsx",
                     str(root / "frontend/src/main.tsx")):
        args = [arg.replace("%{buffer_name}", filename) for arg in formatter["args"]]
        result = subprocess.run(
            [formatter["command"], *args], cwd=root / "frontend/src",
            input=source, text=True, capture_output=True, check=True,
        )
        assert result.stdout == expected, (language["name"], filename, result.stdout)

print("PASS: Helix formatter working directory, import sorting, and formatting")
