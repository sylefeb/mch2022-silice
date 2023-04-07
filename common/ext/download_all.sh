#!/bin/bash
SILICE_URL=https://raw.githubusercontent.com/sylefeb/Silice/draft
MCH2022_SILICE_URL=https://raw.githubusercontent.com/sylefeb/mch2022-silice/main/
MCH2022_TOOLS_URL=https://raw.githubusercontent.com/badgeteam/mch2022-tools/master/
MCH2022_ICE40_URL=https://raw.githubusercontent.com/badgeteam/mch2022-firmware-ice40/master/
OPT=-nc
wget $OPT $MCH2022_ICE40_URL/cores/spi_slave/rtl/spi_dev_core.v
wget $OPT $MCH2022_ICE40_URL/cores/spi_slave/rtl/spi_dev_proto.v
wget $OPT $MCH2022_ICE40_URL/cores/spi_slave/rtl/spi_dev_fread.v
wget $OPT https://raw.githubusercontent.com/no2fpga/no2misc/59350da954e78424117ed01c55b5c7a12e524397/rtl/ram_sdp.v
wget $OPT $SILICE_URL/projects/common/uart.si
wget $OPT $SILICE_URL/projects/spiflash/ddr_clock.v
wget $OPT $SILICE_URL/projects/common/ice40_sb_io.v
wget $OPT $SILICE_URL/projects/common/ice40_sb_io_ddr.v
wget $OPT $SILICE_URL/projects/common/ice40_sb_io_inout.v
wget $OPT $SILICE_URL/projects/common/ddr.v
wget $OPT $SILICE_URL/projects/common/plls/icebrkr_20.v
wget $OPT $SILICE_URL/projects/common/plls/icebrkr_25.v
wget $OPT $SILICE_URL/projects/common/plls/icebrkr_50.v
wget $OPT $SILICE_URL/projects/common/plls/icebrkr_30.v
wget $OPT $MCH2022_TOOLS_URL/fpga.py
