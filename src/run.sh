#! /bin/sh
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd ${SCRIPT_DIR}

.venv-speedrun/Scripts/python.exe -m speedrun ./config/megaman2.yaml
