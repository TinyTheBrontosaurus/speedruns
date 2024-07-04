
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
            root = root_og / raw["root"]

        if len(raw["states"]) > savestate_count:
            raise SaveStateSetSelectorConfigException(f"Too many states in {self._name}")

        self._states = []
        success = True
        for state_cfg in raw["states"]:
            state = SaveState(file=root / state_cfg["file"],
                              description=state_cfg["description"])

            if not state.file.is_file():
                logger.error(f"Source save state does not exist {state.file} ({state.description})")
                success = False

            self._states.append(state)

        if not success:
            raise SaveStateSetSelectorConfigException(


class SaveStateSetSelectorConfig:
    def __init__(self, raw):
        self._root = Path(raw["root"])
        if not self._root.is_dir():
            raise SaveStateSetSelectorConfigException(
                f"Root directory does not exist: {self._root}")

        self._dest_prefix = str(raw["destination-prefix"])
        dest_prefix_abs = definitions.FCEUX_DIR / self._dest_prefix

        # Check to be sure each save state exists. Only warn if it does not exist since
        # it may indicate a typo in the config.
        for savestatei in range(savestate_count):
            dest = dest_prefix_abs + str(savestatei)
            if not dest.is_file():
                logger.warning(f"Destination file does not exist: {dest}")


        self._sets = [SaveStateSetConfig(x, self._root) for x in raw["savestate-configs"]]



class SaveStateSetSelector:
    def __init__(self, config):
        self.config = SaveStateSetSelectorConfig(config)



def main(argv):

    parser = argparse.ArgumentParser("FCEUX save state helper")
    parser.add_argument("config", type=str)
    parsed = parser.parse_args(argv)

    config_filename = parsed.config

    with Path(config_filename).open() as f:
        config = yaml.safe_load(f)

    savestate_set_selector = SaveStateSetSelector(config)