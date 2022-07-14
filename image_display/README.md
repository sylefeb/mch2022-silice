# Image viewer loading a file through SPI fread

This demo shows how to load data from a file on the SDcard using the ESP32 file
loading service provided to the FPGA through the SPI interface.

The main design is written in Silice, using the core functionality that is written in Verilog.
The wrapper around the Verilog designs for loading through SPI is in [spi_file.v](spi_file.v).

## Testing

Simply run `make`. The file does not have to be on the SDcard, as the Makefile will use
the `webusb_fpga` tool to send it alongside the bitstream.

To place the file on the SDcard, copy `image.raw` at the root and give it the name `fpga_bfbfbfbf.dat`.
Then the badge can be programmed without sending the file:
```../common/webusb_fpga.py BUILD_mch2022/build.bin```

## Image format

The image is a raw dump, 8 bit per pixel grayscale, 240x320 (it is stored 'on its side').

## Credits
- The SPI file service is [designed by @smunaut](https://github.com/badgeteam/mch2022-firmware-ice40/tree/master/cores/spi_slave). See also [this file](https://github.com/badgeteam/mch2022-firmware-esp32/blob/master/main/fpga_download.c) for the firmware side (that runs on the ESP32).
- The wrapper in [spi_file.v](spi_file.v) is directly derived from the one written [by @Mecrisp for its RISCV playground](https://github.com/badgeteam/mch2022-firmware-ice40/tree/master/projects/RISCV-Playground) that runs on the badge too. Check it out!
