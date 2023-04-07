SILICE_DIR=$(dir $(shell which silice))

example:
	yosys -p "synth_ice40 -dsp -json build.json -abc9 -device u -top top" top.v
	nextpnr-ice40 --up5k --freq 12 --package sg48 --json build.json --pcf $(SILICE_DIR)/../frameworks/boards/mch2022/mch2022.pcf --asc build.asc -r --timing-allow-fail
	icepack -s build.asc build.bin
	../../common/ext/fpga.py build.bin
