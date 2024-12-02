# Essen Firmware

Essen is the autofeeder controller PCB for the [Machdyne AF](https://github.com/machdyne/af) project.

This firmware controls the autofeeder and accepts I2C commands from the system controller (Koch).

Each feeder has an 1-byte ID, which is set when the firmware is built.

The sensor may need to be calibrated by changing the AF\_THRES definitions.

## Building

To build the firmware you need to have a RISC-V toolchian installed, see [ch32v003fun](https://github.com/cnlohr/ch32v003fun/wiki/Installation) for setup instructions.

To build the firmware and program Essen (via the SWDIO pin):

```
$ make
```

## License

Essen uses ch32V003fun which is released under the MIT license.
