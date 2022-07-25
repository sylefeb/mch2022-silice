SILICE_DIR=$(dir $(shell which silice))

mch2022: BUILD_mch2022/build.bin program

program: BUILD_mch2022/build.bin prepare
	../common/ext/webusb_fpga.py BUILD_mch2022/build.bin

BUILD_mch2022/build.bin: main.si prepare
	silice-make.py -s main.si -b mch2022 -p basic,lcd -o BUILD_mch2022

prepare:
	pushd . ; cd ../common/ext ; ./download_all.sh ; popd

verilog: main.si prepare
	mkdir -p verilog/export
	# export lcd driver
	silice main.si --output verilog/export/lcd_driver.v \
	--export lcd_driver \
	--frameworks_dir $(SILICE_DIR)/../frameworks/ \
	--framework $(SILICE_DIR)/../frameworks/boards/bare/bare.v
	# produce Verilog design
	make -C verilog

clean:
	rm -rf BUILD_*
