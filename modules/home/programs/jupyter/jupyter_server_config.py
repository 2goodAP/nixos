import subprocess

from jupyterlab_code_formatter.formatters import (
    SERVER_FORMATTERS,
    BaseFormatter,
    handle_line_ending_and_magic,
    logger,
)


class RuffFormatFormatter(BaseFormatter):
    label = "Apply Ruff Format Formatter - Confirmed working for 0.1.3"

    def __init__(self) -> None:
        try:
            from ruff.__main__ import find_ruff_bin  # type: ignore

            self.ruff_bin = find_ruff_bin()
        except (ImportError, FileNotFoundError):
            self.ruff_bin = "ruff"

    @property
    def importable(self) -> bool:
        return True

    @handle_line_ending_and_magic
    def format_code(self, code: str, notebook: bool, **options) -> str:
        process = subprocess.run(
            [self.ruff_bin, "format", "-"],
            input=code,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            check=False,
            encoding="utf-8",
        )

        if process.stderr:
            logger.info(process.stderr)
            return code
        return process.stdout


SERVER_FORMATTERS["ruff_format"] = RuffFormatFormatter()
