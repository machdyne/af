# Koch Firmware

Koch is the autofeeder system controller PCB for the [Machdyne AF](https://github.com/machdyne/af) project.

This firmwire provides a minimal G-code compatible interface over the USB port that can be driven by an OpenPnP GcodeDriver.

Each feeder has an 1-byte ID, which is set when the Essen firmware is built.

## Building

To build the RP2040 firmware, assuming you have [pico-sdk](https://github.com/raspberrypi/pico-sdk) installed:

```
$ mkdir build
$ cd build
$ cmake ..
$ make
```

## OpenPnp Configuration

### Machine Setup

Add a GCodeDriver under Drivers and set the correct serial port, 115200 baud.

Set the driver Gcode value for ACTUATE\_DOUBLE\_COMMAND:

```
K100 {IntegerValue}
```

Add an Actuator that uses the above driver with Value Type of Double.

### Feeder Setup

Add a new feeder and select the above actuator, set the actuator value to the decimal I2C ID of the feeder.

## Gcode Commands

| Command | Description |
| ------- | ----------- |
| K100 \<feeder\_id\> | Advance the specified feeder (ID is base-10) |
| K200 | Motor on full forward |
| K201 | Motor on full reverse |
| K202 | Motor off |
| K900 | Report system status & current usage |
