
import argparse
from pathlib import Path
import yaml
from loguru import logger
from speedrun import definitions
from dataclasses import dataclass
import datetime
import shutil


savestate_count = 10


class SaveStateSetSelectorConfigException(Exception):
    pass


@dataclass
class SaveState:
    file: Path
    description: str


class SaveStateSetConfig:
    def __init__(self, raw, root):
        self._name = raw["name"]
        root_og = root
        if "root" in raw:
            root = root_og / str(raw["root"])

        if len(raw["states"]) > savestate_count:
            raise SaveStateSetSelectorConfigException(f"Too many states in {self._name}")

        self._states = []
        success = True
        for state_cfg in raw["states"]:
            state = SaveState(file=root / state_cfg["file"],
                              description=state_cfg["description"])

            if not state.file.is_file():
                logger.error(f"Source save state does not exist: {state.file} ({state.description})")
                success = False

            self._states.append(state)

        if not success:
            raise SaveStateSetSelectorConfigException("Source files missing. See log.")

    @property
    def name(self):
        return self._name

    @property
    def states(self):
        return self._states


class SaveStateSetSelectorConfig:
    def __init__(self, raw, src_root, dest_root):
        self._root = src_root / raw["root"]
        if not self._root.is_dir():
            raise SaveStateSetSelectorConfigException(
                f"Root directory does not exist: {self._root}")

        self._dest_set = [dest_root / (str(raw["destination-prefix"]) + str((savestatei + 1) % savestate_count))
                          for savestatei in range(savestate_count)]

        # Check to be sure each save state exists. Only warn if it does not exist since
        # it may indicate a typo in the config.
        for dest in self._dest_set:
            if not dest.is_file():
                logger.warning(f"Destination file does not exist: {dest}")

        self._src_sets = [SaveStateSetConfig(x, self._root) for x in raw["savestate-configs"]]

    @property
    def src_sets(self):
        return tuple(self._src_sets)

    @property
    def dest_set(self):
        return tuple(self._dest_set)


class SaveStateSetSelector:
    def __init__(self, config, src_root, dest_root):
        self.config = SaveStateSetSelectorConfig(config, src_root, dest_root)

    def activate(self, selection: int):
        if (selection < 0) or (selection > len(self.config.src_sets)):
            raise SaveStateSetSelectorConfigException(f"Index out of bounds {selection}")

        src_set = self.config.src_sets[selection]

        print(f"Activating {src_set.name} into the following slots")

        for srci, src in enumerate(src_set.states):
            print(f"  {srci + 1} --> {src.description}")
            dest = self.config.dest_set[srci]
            shutil.copy(str(src.file), str(dest))

    def backup(self):
        save_folder = get_log_folder(definitions.BACKUP_DIR)
        for backup_src in self.config.dest_set:
            shutil.copy(str(backup_src), str(save_folder))

        print(f"Existing save states backed up to {save_folder}")


def get_log_folder(root):
    # Setup target log folder
    friendly_time = str(datetime.datetime.now()).replace(':', "-").replace(" ", "_")
    log_folder = root / friendly_time

    # Create the folders
    log_folder.mkdir(parents=True, exist_ok=True)
    return log_folder

def main(argv):

    parser = argparse.ArgumentParser("FCEUX save state helper")
    parser.add_argument("config", type=str)
    parsed = parser.parse_args(argv)

    config_filename = Path(parsed.config)


    reload = True

    while True:
        if reload:
            print("Loading config...")
            with Path(config_filename).open() as f:
                config = yaml.safe_load(f)
            savestate_set_selector = SaveStateSetSelector(config, src_root=config_filename.parent,
                                                          dest_root=definitions.FCEUX_DIR)

        print("\nSave State Set Options:")
        for sseti, sset in enumerate(savestate_set_selector.config.src_sets):
            print(f"{sseti:>3}: {sset.name}")
        print(f"{'R':>3}: Reload")
        print(f"{'Q':>3}: Quit")
        print("Select an option to activate")
        selection_raw = input()
        if selection_raw.lower() == 'q':
            break
        if selection_raw.lower() == 'r':
            reload = True
            continue
        try:
            selection = int(selection_raw)
            savestate_set_selector.backup()
            savestate_set_selector.activate(selection)
        except Exception as e:
            logger.error(e)
    print("Goodbye")

