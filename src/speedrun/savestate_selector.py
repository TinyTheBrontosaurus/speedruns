
import argparse
from pathlib import Path
import yaml
from loguru import logger
from speedrun import definitions
from dataclasses import dataclass


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


class SaveStateSetSelectorConfig:
    def __init__(self, raw, src_root, dest_root):
        self._root = src_root / raw["root"]
        if not self._root.is_dir():
            raise SaveStateSetSelectorConfigException(
                f"Root directory does not exist: {self._root}")

        self._dest_prefix = str(raw["destination-prefix"])

        # Check to be sure each save state exists. Only warn if it does not exist since
        # it may indicate a typo in the config.
        for savestatei in range(savestate_count):
            dest = dest_root / (self._dest_prefix + str(savestatei))
            if not dest.is_file():
                logger.warning(f"Destination file does not exist: {dest}")


        self._sets = [SaveStateSetConfig(x, self._root) for x in raw["savestate-configs"]]



class SaveStateSetSelector:
    def __init__(self, config, src_root, dest_root):
        self.config = SaveStateSetSelectorConfig(config, src_root, dest_root)



def main(argv):

    parser = argparse.ArgumentParser("FCEUX save state helper")
    parser.add_argument("config", type=str)
    parsed = parser.parse_args(argv)

    config_filename = Path(parsed.config)

    with Path(config_filename).open() as f:
        config = yaml.safe_load(f)

    savestate_set_selector = SaveStateSetSelector(config, src_root=config_filename.parent, dest_root=definitions.FCEUX_DIR)