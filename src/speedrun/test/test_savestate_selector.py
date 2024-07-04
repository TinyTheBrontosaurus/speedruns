from speedrun import savestate_selector
import pytest
from dataclasses import dataclass
from pathlib import Path

@dataclass
class ValidSetup:
    src: Path
    dest: Path
    cfg: dict



@pytest.fixture
def valid_setup(tmpdir):
    src = Path(tmpdir / "src")
    dest = Path(tmpdir / "dest")

    cfg = {
        "root": ".",
        "destination-prefix": "Game Name.fc",
        "savestate-configs": [
            {
                "name": "test1",
                "states": [
                    {
                        "description": "desc1",
                        "file": "parent/child/file.fc0"
                    },
                    {
                        "description": "desc2",
                        "file": "parent/child/file2.fc0"
                    }
                ]
            }
        ]
    }

    (src / "parent" / "child").mkdir(parents=True, exist_ok=True)
    (src / "parent" / "child" / "file.fc0").touch()
    (src / "parent" / "child" / "file2.fc0").touch()
    (dest).mkdir(parents=True, exist_ok=True)
    (dest / "Game Name.fc0").touch()
    (dest / "Game Name.fc1").touch()
    (dest / "Game Name.fc2").touch()
    (dest / "Game Name.fc3").touch()
    (dest / "Game Name.fc4").touch()
    (dest / "Game Name.fc5").touch()
    (dest / "Game Name.fc6").touch()
    (dest / "Game Name.fc7").touch()
    (dest / "Game Name.fc8").touch()
    (dest / "Game Name.fc9").touch()

    return ValidSetup(src, dest, cfg)


def test_valid(valid_setup, caplog):
    """Check that nominal execution throws no warnings"""
    # Arrange

    # Act
    object_under_test = savestate_selector.SaveStateSetSelectorConfig(valid_setup.cfg, valid_setup.src, valid_setup.dest)

    # Assert
    assert len(caplog.messages) == 0

def test_missing_dest_1(valid_setup, caplog):
    """Check that warnings are printed when dest files are missing"""
    # Arrange
    (valid_setup.dest / "Game Name.fc1").unlink()

    # Act
    object_under_test = savestate_selector.SaveStateSetSelectorConfig(valid_setup.cfg, valid_setup.src, valid_setup.dest)

    # Assert
    assert len(caplog.messages) == 1
    assert "Destination file does not exist:" in caplog.messages[0]


def test_missing_dest_2(valid_setup, caplog):
    """Check that warnings are printed when 2 dest files are missing"""
    # Arrange
    (valid_setup.dest / "Game Name.fc1").unlink()
    (valid_setup.dest / "Game Name.fc9").unlink()

    # Act
    object_under_test = savestate_selector.SaveStateSetSelectorConfig(valid_setup.cfg, valid_setup.src, valid_setup.dest)

    # Assert
    assert len(caplog.messages) == 2
    assert "Destination file does not exist:" in caplog.messages[0]
    assert "Destination file does not exist:" in caplog.messages[1]


def test_missing_src_1(valid_setup, caplog):
    """Check that exceptions are thrown when src files are missing"""
    # Arrange
    (valid_setup.src / "parent" / "child" / "file.fc0").unlink()

    # Act / Assert
    with pytest.raises(savestate_selector.SaveStateSetSelectorConfigException):
        savestate_selector.SaveStateSetSelectorConfig(valid_setup.cfg, valid_setup.src, valid_setup.dest)

    # Assert
    assert len(caplog.messages) == 1
    assert "Source save state does not exist:" in caplog.messages[0]


def test_missing_src_2(valid_setup, caplog):
    """Check that exceptions are thrown when src files are missing"""
    # Arrange
    (valid_setup.src / "parent" / "child" / "file.fc0").unlink()
    (valid_setup.src / "parent" / "child" / "file2.fc0").unlink()

    # Act / Assert
    with pytest.raises(savestate_selector.SaveStateSetSelectorConfigException):
        savestate_selector.SaveStateSetSelectorConfig(valid_setup.cfg, valid_setup.src, valid_setup.dest)

    # Assert
    assert len(caplog.messages) == 2
    assert "Source save state does not exist:" in caplog.messages[0]
    assert "Source save state does not exist:" in caplog.messages[1]
