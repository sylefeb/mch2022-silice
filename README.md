# mch2022-silice
Silice designs for the MCH2022 badge

For setting up Silice please refer [to its repository](https://github.com/sylefeb/Silice).

The Silice `bin/` directory has to be in the path, as well as yosys and nextpnr-ice40 (using latest versions is recommended).

> I am writing a new tutorial for Silice which [can be find here](https://github.com/sylefeb/Silice/blob/draft/learn-silice/README.md). It also contains a brief introduction to hardware design on FPGA.

> I also made a small GPU and accompanying graphical demos that run on the badge. [Check it out here!](https://github.com/sylefeb/tinygpus)

## Building something

Connect the badge, enter the project directory (for instance `lcd_test`) and type `make`. Enjoy!

> The `qpsram_loader` directory contains a project to upload and download data to PSRAM from memory that will not automatically program the badge.

## Credits:
- Thanks to the FPGA badge team for fun, guidance and inspiring projects https://github.com/badgeteam/mch2022-firmware-ice40
- Thanks to the badge team for an awesome badge https://github.com/badgeteam/
- FPGA upload tool: https://github.com/badgeteam/mch2022-tools
