# Keyboard Firmware Scripts

This directory contains scripts for managing the keyboard firmware.

## `zmk_util`

This is the main script for building, flashing, and resetting the keyboard firmware.

### Usage

```bash
./zmk_util <command> [options]
```

### Commands

*   `build`: Build the firmware for the left and/or right hand keyboard.
*   `flash`: Flash the firmware to the keyboard.
*   `reset`: Reset the keyboard.
*   `tty`: Connect to the serial output of the keyboards.

### Configuration

The script's behavior can be configured through a configuration file, environment variables, or command-line arguments. The order of precedence is as follows (from lowest to highest):

1.  **`default_config.sh` file**: This file, located in the `scripts` directory, provides the base configuration. You can edit it to set your most common options.
2.  **Environment Variables**: You can override the settings from the config file by exporting environment variables in your shell. For example: `export TARGET_MCU="rp2350"`.
3.  **Command-line Flags**: The flags passed to the `zmk_util` script will always take the highest precedence. For example: `./zmk_util build --target rp2350`.

### Configuration Options

The following variables can be configured:

| Variable                  | Description                                                              | Options / Example        |
| ------------------------- | ------------------------------------------------------------------------ | ------------------------ |
| `TARGET_MCU`              | The target microcontroller unit.                                         | `rp2040`, `rp2350`       |
| `LEFT_RUNNER`             | The runner to use for flashing the left keyboard half.                   | `jlink`, `openocd`       |
| `RIGHT_RUNNER`            | The runner to use for flashing the right keyboard half.                  | `jlink`, `openocd`       |
| `LEFT_INTERFACE`          | The debug interface for the left half (used with `openocd`).             | `jlink`, `cmsis-dap`     |
| `RIGHT_INTERFACE`         | The debug interface for the right half (used with `openocd`).            | `jlink`, `cmsis-dap`     |
| `LEFT_PORT`               | The serial port for the left keyboard half.                              | `/dev/ttyACM0`           |
| `RIGHT_PORT`              | The serial port for the right keyboard half.                             | `/dev/ttyACM1`           |
| `PICO_SDK_OPENOCD_PATH`   | The path to the OpenOCD scripts for the Pico SDK.                        | `/path/to/pico/sdk/openocd/scripts` |

For a full list of command-line flags and their corresponding configuration variables, run:

```bash
./zmk_util --help
```
