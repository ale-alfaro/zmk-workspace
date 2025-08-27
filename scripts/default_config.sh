# -----------------------------------------------------------------------------
# Default Configuration for zmk_util script
# -----------------------------------------------------------------------------
# This file contains the default settings for the zmk_util script.
# You can override these settings by exporting environment variables in your
# shell or by using command-line flags when running the script.
# -----------------------------------------------------------------------------

# --- General Configuration ---

# Target MCU
# The microcontroller unit of your keyboard.
# Options: "rp2040", "rp2350"
export TARGET_MCU="rp2040"


# --- Debugging and Flashing ---

# Runner for the left keyboard half.
# This determines the tool used for flashing.
# Options: "jlink", "openocd"
export LEFT_RUNNER="jlink"

# Runner for the right keyboard half.
export RIGHT_RUNNER="openocd"

# Debug interface for the left half (used with openocd).
# Options: "jlink", "cmsis-dap", etc. (any valid openocd interface config)
export LEFT_INTERFACE="jlink"

# Debug interface for the right half (used with openocd).
export RIGHT_INTERFACE="cmsis-dap"


# --- Serial Ports ---

# Serial port for the left keyboard half.
# You can find the port by running `ls /dev/ttyACM*` after plugging in the board.
export LEFT_PORT="/dev/ttyACM0"

# Serial port for the right keyboard half.
export RIGHT_PORT="/dev/ttyACM1"


# --- OpenOCD Path ---

# Path to the OpenOCD scripts directory for the Pico SDK.
# If left empty, the script will try to find it in the default location
# (~/.pico-sdk/openocd).
export PICO_SDK_OPENOCD_PATH=""