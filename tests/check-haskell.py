from pathlib import Path
import subprocess
root = Path(__file__).resolve().parents[1]
expression = (root / 'tests/haskell-checks.expr').read_text()
subprocess.run(['ghc', '-ignore-dot-ghci', str(root / 'haskell/48.hs'), '-e', expression], check=True)
