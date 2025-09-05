# Analysis of Zephyr GPIO Keyboard Matrix Driver for RP2350 Errata

This document summarizes the analysis of the Zephyr GPIO keyboard matrix driver and provides a successful workaround for the RP2350 GPIO pull-down errata.

## Background

The Sparkfun Pro Micro RP2350 board uses a microcontroller with an errata affecting GPIO pull-down resistors, making them unreliable. This posed a problem for the Corne keyboard shield, which is designed to use pull-downs on its row-input pins.

## Recommended Workaround

The recommended and implemented workaround is to invert the matrix scanning logic in software to completely avoid using the faulty pull-down resistors. This is achieved by modifying the device tree overlay.

### How it Works

1.  **Swap Rows and Columns:** The physical rows of the keyboard are assigned to `col-gpios` in the overlay, and the physical columns are assigned to `row-gpios`.
2.  **Use Pull-Ups:** The new `row-gpios` (the physical columns) are configured as inputs with internal pull-up resistors and are set to be "active low" by using the `(GPIO_PULL_UP | GPIO_ACTIVE_LOW)` flags. This means they are held high by default, and a low signal is considered a key press.
3.  **Drive Columns Low:** The new `col-gpios` (the physical rows) are configured to be "active low" by using the `GPIO_ACTIVE_LOW` flag. The driver will treat them as outputs and drive them to a low state one by one during the scan.

This configuration bypasses the need for pull-down resistors entirely and uses the RP2350's reliable internal pull-ups instead.

## Project Summary and Final Outcome

This project involved adapting the Corne keyboard shield to work with the Sparkfun Pro Micro RP2350, which has a known hardware errata affecting its GPIO pull-down resistors. Here is a summary of the steps we took to create a successful software workaround:

1.  **Problem Identification**: We established that the RP2350's faulty pull-downs were incompatible with the Corne PCB's reliance on pull-downs for its matrix row inputs.

2.  **Core Strategy**: To solve this, we developed a software-only workaround that completely avoids using pull-down resistors. The strategy was to invert the keyboard matrix logic within the Zephyr device tree:
    *   Physical rows were treated as logical columns.
    *   Physical columns were treated as logical rows.
    *   This allowed us to use the RP2350's reliable internal **pull-up** resistors on the new logical rows.

3.  **Implementation via Device Tree**:
    *   **GPIO Configuration**: We modified the `rp2350` shield overlays, swapping the `row-gpios` and `col-gpios` assignments and applying the correct flags (`GPIO_PULL_UP | GPIO_ACTIVE_LOW` for new rows, `GPIO_ACTIVE_LOW` for new columns).
    *   **Layout and Keymap**: To manage the complexity of the flipped axes, we created ASCII art diagrams for both the left and right keyboard halves. These diagrams were used to correctly transpose the `keymap` for the new configuration.
    *   **Optimization**: We fine-tuned the driver's behavior by setting `idle-mode = "interrupt";` for power efficiency and `no-ghostkey-check;` since the hardware has diodes. We also calculated and set the `actual-key-mask` property based on the new flipped layout to precisely define the matrix shape for the driver.

4.  **Verification**: The process concluded with a successful test. You ran the `input_dump` sample, and the output showed that individual key presses were detected correctly at their new, transposed matrix coordinates. This confirmed that the workaround was fully functional.

Ultimately, by thoroughly analyzing the driver and applying a creative device tree configuration, we successfully enabled the Corne keyboard on the new RP2350 hardware, completely bypassing the hardware limitation.

---

# Appendix

## A. Device Tree Bindings

These are the binding files that define the properties available for the `gpio-kbd-matrix` compatible node.

### `gpio-kbd-matrix.yaml`
```yaml
# Copyright 2023 Google LLC
# SPDX-License-Identifier: Apache-2.0

description: |
  GPIO based keyboard matrix input device

  Implement an input device for a GPIO based keyboard matrix.

  Example configuration:

  kbd-matrix {
          compatible = "gpio-kbd-matrix";
          row-gpios = <&gpio0 0 (GPIO_PULL_UP | GPIO_ACTIVE_LOW)>,
                      <&gpio0 1 (GPIO_PULL_UP | GPIO_ACTIVE_LOW)>;
          col-gpios = <&gpio0 2 GPIO_ACTIVE_LOW>,
                      <&gpio0 3 GPIO_ACTIVE_LOW>,
                      <&gpio0 4 GPIO_ACTIVE_LOW>;
          no-ghostkey-check;
  };

compatible: "gpio-kbd-matrix"

include:
  - name: kbd-matrix-common.yaml
    property-blocklist:
      - row-size
      - col-size

properties:
  row-gpios:
    type: phandle-array
    required: true
    description: |
      GPIO for the keyboard matrix rows, up to 8 different GPIOs. All row GPIO
      pins must have interrupt support if idle-mode is set to "interrupt"
      (default).

  col-gpios:
    type: phandle-array
    required: true
    description: |
      GPIO for the keyboard matrix columns, supports up to 32 different GPIOs.
      When unselected, this pin will be either driven to inactive state or
      configured to high impedance (input) depending on the col-drive-inactive
      property.

  col-drive-inactive:
    type: boolean
    description: |
      If enabled, unselected column GPIOs will be driven to inactive state.
      Default to configure unselected column GPIOs to high impedance.

  idle-mode:
    type: string
    default: "interrupt"
    enum:
      - "interrupt"
      - "poll"
      - "scan"
    description: |
      Controls the driver behavior on idle, "interrupt" waits for a new key
      press using GPIO interrupts on the row lines, "poll"  periodically polls
      the row lines with all the columns selected, "scan" just keep scanning
      the matrix continuously, requires "poll-timeout-ms" to be set to 0.
```

### `kbd-matrix-common.yaml`
```yaml
# SPDX-License-Identifier: Apache-2.0

description: Keyboard matrix device

include: base.yaml

properties:
  row-size:
    type: int
    description: |
      The number of rows in the keyboard matrix.

  col-size:
    type: int
    description: |
      The number of column in the keyboard matrix.

  poll-period-ms:
    type: int
    default: 5
    description: |
      Defines the poll period in msecs between between matrix scans, set to 0
      to never exit poll mode. Defaults to 5ms if unspecified.

  stable-poll-period-ms:
    type: int
    description: |
      Defines the poll period in msecs between matrix scans when the matrix is
      stable, defaults to poll-period-ms value if unspecified.

  poll-timeout-ms:
    type: int
    default: 100
    description: |
      How long to wait before going from polling back to idle state. Defaults
      to 100ms if unspecified.

  debounce-down-ms:
    type: int
    default: 10
    description: |
      Debouncing time for a key press event. Defaults to 10ms if unspecified.

  debounce-up-ms:
    type: int
    default: 20
    description: |
      Debouncing time for a key release event. Defaults to 20ms if unspecified.

  settle-time-us:
    type: int
    default: 50
    description: |
      Delay between setting column output and reading the row values. Defaults
      to 50us if unspecified.

  actual-key-mask:
    type: array
    description:
      Keyboard scanning mask. For each keyboard column, specify which
      keyboard rows actually exist. Can be used to avoid triggering the ghost
      detection on non existing keys. No masking by default, any combination is
      valid.

  no-ghostkey-check:
    type: boolean
    description: |
        Ignore the ghost key checking in the driver if the diodes are used
        in the matrix hardware.
```

## B. Driver Analysis Notes

### `col-drive-inactive` Property

This boolean property determines the strategy for driving columns.
*   **`false` (default):** Inactive columns are set to `GPIO_INPUT` (high-impedance). To activate a column, the driver reconfigures it to `GPIO_OUTPUT_ACTIVE`. This is safer against shorts. Our solution uses this default behavior.
*   **`true`:** Columns are always outputs. Inactive columns are driven to their inactive state (HIGH for an `ACTIVE_LOW` pin). Active columns are driven to their active state (LOW). This can be slightly faster.

### `idle-mode` Property

This property controls power consumption when the keyboard is not in use.
*   **`"interrupt"` (recommended):** Most power-efficient. The driver sleeps and waits for a GPIO interrupt on a key press.
*   **`"poll"`:** Less efficient. The driver periodically wakes up to quickly check for key presses.
*   **`"scan"`:** Least efficient. The driver scans the matrix continuously.

We chose `"interrupt"` for the best power performance.

### `no-ghostkey-check` Property

This boolean property disables the driver's software algorithm for detecting "ghost" key presses. We disabled this because the Corne keyboard has per-key diodes, which is the hardware solution for ghosting, making the software check redundant.

---

# Project Development Notes

This section contains notes on the project structure and bookmarks to important files for quick reference during development.

## Project Structure

The firmware project is organized into three main directories:

*   `zmk/`: This is the main ZMK firmware repository, containing the core application logic and default board/shield configurations.
    *   `app/`: The ZMK application itself. This is where most of the core ZMK features are implemented.
        *   `src/`: The C source code for ZMK's features like keymaps, behaviors, split keyboard communication, etc.
        *   `boards/`: Contains the default board definitions and shield overlays that are part of the main ZMK project.
    *   `zephyr/`: A submodule pointing to the Zephyr RTOS, which forms the foundation of ZMK.

*   `zmk-config/`: This is your personal user configuration for your keyboard. It's where you define your keymap and enable specific features.
    *   `config/`: Contains your personal `.conf` and `.keymap` files.
    *   `build.yaml`: The build matrix configuration file used to generate firmware for different board and shield combinations.
    *   `justfile`: A local `justfile` for managing tasks related to your personal configuration.

*   `zmk_playground_module/`: Your custom ZMK module. This is the perfect place to keep experimental or personal board and shield definitions that are not part of the official ZMK repository.
    *   `boards/`: Contains your custom board and shield definitions, like the `corne_keyboard` shield we are working on.

## Bookmarked Files

Here is a list of important files and their purpose.

*   **ZMK Core & Integration:**
    *   `zmk/app/src/physical_layouts.c`: **The main integration point.** This file contains the logic that receives events from both the legacy `kscan` drivers and the new `input` subsystem drivers. It processes these events and sends them to the rest of the ZMK engine.
    *   `zmk/app/src/keymap.c`: The core keymap logic that manages layers.
    *   `zmk/app/src/behavior.c`: The implementation of ZMK's powerful behavior system (mod-taps, layer-taps, etc.).
    *   `zmk/app/src/zmk.c`: The main application entry point.

*   **Your Configuration:**
    *   `zmk-config/config/`: The directory holding your active keyboard `.conf` and `.keymap` files.
    *   `zmk-config/build.yaml`: The file defining all your build targets.
    *   `zmk_playground_module/boards/shields/corne_keyboard/`: The directory for the shield we are currently developing.

*   **Driver APIs & Bindings:**
    *   `zmk/zephyr/include/zephyr/drivers/kscan.h`: The header file for the legacy `kscan` API.
    *   `zmk/zephyr/include/zephyr/input/input.h`: The header file for the modern Zephyr `input` subsystem API.
    *   `zmk/zephyr/dts/bindings/input/gpio-kbd-matrix.yaml`: The binding file for the new GPIO matrix driver.