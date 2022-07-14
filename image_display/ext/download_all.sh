#!/bin/bash
MCH2022_ICE40_URL=https://raw.githubusercontent.com/badgeteam/mch2022-firmware-ice40/master/
OPT=-nc
wget $OPT $MCH2022_ICE40_URL/cores/spi_slave/rtl/spi_dev_core.v
wget $OPT $MCH2022_ICE40_URL/cores/spi_slave/rtl/spi_dev_proto.v
wget $OPT $MCH2022_ICE40_URL/cores/spi_slave/rtl/spi_dev_fread.v
wget $OPT https://raw.githubusercontent.com/no2fpga/no2misc/59350da954e78424117ed01c55b5c7a12e524397/rtl/ram_sdp.v
