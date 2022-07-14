#!/bin/bash
SILICE_URL=https://raw.githubusercontent.com/sylefeb/Silice/draft
MCH2022_SILICE_URL=https://raw.githubusercontent.com/sylefeb/mch2022-silice/main/
MCH2022_ICE40_URL=https://github.com/badgeteam/mch2022-firmware-ice40/blob/master/
MCH2022_TOOLS_URL=https://raw.githubusercontent.com/badgeteam/mch2022-tools/master/
OPT=-nc
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
wget $OPT $MCH2022_TOOLS_URL/webusb_fpga.py
