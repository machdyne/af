# Machdyne AF

## Overview

Machdyne AF is an open-source project for a PNP autofeeder system.

The autofeeder design is a closed-loop system that uses an infrared LED and phototransistor array to precisely detect the tape position. The tape is moved forward using a geared DC motor and a sprocket. The cover tape is partially separated and advanced with the tape.

The autofeeders can be chained together with 4 wires and communicate with the system controller using the I2C protocol.

The system uses two custom printed circuit board designs. An autofeeder controller PCB (Essen) includes the tape detection and motor driver circuitry for each autofeeder. A system controller PCB (Koch) provides power and allows a chain of feeders to communicate with the OpenPnP software over a USB-C port.

## System Components

### 3D printable parts

The 3D printable parts and assembly instructions will be made available soon.

### Autofeeder controller (Essen)

![Essen](essen.png)

#### Pinout (Rear)

```
9  7  5  3  1
10 8  6  4  2
```

| Pin | Signal | Notes |
| --- | ------ | ----- |
| 9/10 | 12V | System power input |
| 7/8 | GND | Ground |
| 5/6 | SDA | I2C data |
| 3/4 | SCL | I2C clock |
| 2 | TRIGGER | Optional external tape advance signal |
| 1 | SWDIO | MCU SWD signal for firmware updates / serial debugging output |

#### Pinout (Top)

| Pin | Signal | Notes |
| --- | ------ | ----- |
| 1 | MOT1 | Motor driver output #1 |
| 2 | GND | Ground |
| 3 | MOT2 | Motor driver output #2 |
| 4 | GND | Ground |
| 5 | ELED\_A | External (IR) LED anode |
| 6 | ELED\_K | External (IR) LED cathode |

The motor driver can drive one bidirectional motor or two unidirectional motors.

### System controller (Koch)

![Koch](koch.png)

#### Pinout

```
1 2 3 4
```

| Pin | Signal | Notes |
| --- | ------ | ----- |
| 1 | 12V | System power output |
| 2 | GND | System ground |
| 3 | SDA | I2C data |
| 4 | SCL | I2C clock |

## Funding

This project is being partially funded through the [NGI0 Entrust Fund](https://nlnet.nl/entrust/), a fund established by NLnet with financial support from the European Commission's Next Generation Internet programme.

## License

This project is released under the [CERN-OHL-P](LICENSE.txt) license.
