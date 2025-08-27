#!/bin/bash

# This is a configuration file for the keyboard.sh script.
# You can override these values by setting them in your environment.

# --- General Configuration ---
# Target MCU: rp2040 or rp2350
# export TARGET_MCU="rp2040"

# --- Debugging and Flashing ---
# Debug runner for left side: jlink or openocd
# export LEFT_RUNNER="jlink"
# Debug runner for right side: jlink or openocd
# export RIGHT_RUNNER="openocd"

# Debug interface for left side (for openocd): e.g., jlink, cmsis-dap
# export LEFT_INTERFACE="jlink"
# Debug interface for right side (for openocd): e.g., jlink, cmsis-dap
# export RIGHT_INTERFACE="cmsis-dap"


# --- Serial Ports ---
# You can find the serial port by running 'ls /dev/ttyACM*' after plugging in the board.
# Serial port for the left side
# export LEFT_PORT="/dev/ttyACM0"
# Serial port for the right side
# export RIGHT_PORT="/dev/ttyACM1"

# --- OpenOCD Path ---
# Path to openocd scripts. If not set, the script will try to find it.
# export PICO_SDK_OPENOCD_PATH=""
