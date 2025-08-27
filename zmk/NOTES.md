
# Notes

## DTS files for the keyboard. There's 3 different sources for the DTS files:
 1. DTS files of the board (i.e nice_nano)
 2. DTS overlay files for the shield representing the keyboard that the MCU is being used with (i.e Corne)
 3. Keymap files for the keyboard (i.e nice_nano.keymap)

### nice_nano


```sh
-- Found BOARD.dts: /home/alealfaro/GeekieStuff/dyi-keyboard/zmk-zephyr-v4.1/app/boards/nicekeyboards/nice_nano/nice_nano.dts
-- Found devicetree overlay: /home/alealfaro/GeekieStuff/dyi-keyboard/zmk-zephyr-v4.1/app/boards/nicekeyboards/nice_nano/nice_nano_2_0_0.overlay
-- Found devicetree overlay: /home/alealfaro/GeekieStuff/dyi-keyboard/zmk-zephyr-v4.1/app/boards/shields/corne/corne_left.overlay
-- Found devicetree overlay: /home/alealfaro/GeekieStuff/dyi-keyboard/zmk-zephyr-v4.1/app/boards/shields/corne/boards/nice_nano.overlay
-- Found devicetree overlay: /home/alealfaro/GeekieStuff/dyi-keyboard/zmk-config/config/corne.keymap
```

```dts zmk-zephyr-v4.1/app/boards/nicekeyboards/nice_nano/nice_nano.dts

/dts-v1/;

#include <nordic/nrf52840_qiaa.dtsi>
#include <common/nordic/nrf52840_uf2_boot_mode.dtsi>
#include "nice_nano-pinctrl.dtsi"
#include "arduino_pro_micro_pins.dtsi"


/ {
    model = "nice!nano";
    compatible = "nice,nano";

    chosen {
        zephyr,code-partition = &code_partition;
        zephyr,sram = &sram0;
        zephyr,flash = &flash0;
    };

    leds {
        compatible = "gpio-leds";
        blue_led: led_0 {
            gpios = <&gpio0 15 GPIO_ACTIVE_HIGH>;
        };
    };
};

&reg1 {
    regulator-initial-mode = <NRF5X_REG_MODE_DCDC>;
};

&adc {
    status = "okay";
};

&gpiote {
    status = "okay";
};

&gpio0 {
    status = "okay";
};

&gpio1 {
    status = "okay";
};

&i2c0 {
    compatible = "nordic,nrf-twi";
    pinctrl-0 = <&i2c0_default>;
    pinctrl-1 = <&i2c0_sleep>;
    pinctrl-names = "default", "sleep";
};

&spi1 {
    compatible = "nordic,nrf-spim";
    pinctrl-0 = <&spi1_default>;
    pinctrl-1 = <&spi1_sleep>;
    pinctrl-names = "default", "sleep";
};

&uart0 {
    compatible = "nordic,nrf-uarte";
    current-speed = <115200>;
    pinctrl-0 = <&uart0_default>;
    pinctrl-1 = <&uart0_sleep>;
    pinctrl-names = "default", "sleep";
};

zephyr_udc0: &usbd {
    status = "okay";
};


&flash0 {
    /*
     * For more information, see:
     * http://docs.zephyrproject.org/latest/devices/dts/flash_partitions.html
     */
    partitions {
        compatible = "fixed-partitions";
        #address-cells = <1>;
        #size-cells = <1>;

        sd_partition: partition@0 {
            reg = <0x00000000 0x00026000>;
        };
        code_partition: partition@26000 {
            reg = <0x00026000 0x000c6000>;
        };

        /*
         * The flash starting at 0x000ec000 and ending at
         * 0x000f3fff is reserved for use by the application.
         */

        /*
         * Storage partition will be used by FCB/LittleFS/NVS
         * if enabled.
         */
        storage_partition: partition@ec000 {
            reg = <0x000ec000 0x00008000>;
        };

        boot_partition: partition@f4000 {
            reg = <0x000f4000 0x0000c000>;
        };
    };
};
```

```dts zmk-zephyr-v4.1/app/boards/nicekeyboards/nice_nano/nice_nano_2_0_0.overlay

/ {
    chosen {
        zmk,battery = &vbatt;
    };

    // Node name must match original "EXT_POWER" label to preserve user settings.
    EXT_POWER {
        compatible = "zmk,ext-power-generic";
        control-gpios = <&gpio0 13 GPIO_ACTIVE_HIGH>;
        init-delay-ms = <50>;
    };

    vbatt: vbatt {
        compatible = "zmk,battery-nrf-vddh";
    };
};

&reg0 {
    status = "okay";
};
```
