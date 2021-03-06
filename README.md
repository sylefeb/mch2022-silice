# mch2022-silice
Silice designs for the MCH2022 badge

For setting up Silice please refer [to its repository](https://github.com/sylefeb/Silice).

The Silice `bin/` directory has to be in the path, as well as yosys and nextpnr-ice40 (using latest versions is recommended). For the Doomfire effect, the riscv toolchain
is required.

> I am writing a new tutorial for Silice which [can be found here](https://github.com/sylefeb/Silice/tree/master/learn-silice). It also contains a brief introduction to hardware design on FPGA.

> I also made a small GPU and accompanying graphical demos that run on the badge. [Check it out here!](https://github.com/sylefeb/tinygpus)

## Building something

Connect the badge, enter the project directory (for instance `lcd_test`) and type `make`. Enjoy!

> A good starting point is the [LCD test](./lcd_test/README.md), which is a small design producing a simple on-screen pattern.

> The [Doomfire](./doomfire/README.md) is also fully documented, it uses Silice RISCV integration to generate a Doom fire from a CPU embedded into a simple hardware driving the lcd screen.

> The `qpsram_loader` directory contains a project to upload and download data to PSRAM from memory that will not automatically program the badge.

## Credits:
- Thanks to the FPGA badge team for fun, guidance and inspiring projects https://github.com/badgeteam/mch2022-firmware-ice40
- Thanks to the badge team for an awesome badge https://github.com/badgeteam/
- FPGA upload tool: https://github.com/badgeteam/mch2022-tools
