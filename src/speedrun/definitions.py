from pathlib import Path

ROOT_DIR = Path(__file__).parent.parent
LOG_DIR = ROOT_DIR / "log"
BACKUP_DIR = ROOT_DIR / "backup"
FCEUX_DIR = ROOT_DIR.parent.parent / "fceux" / "fcs"
