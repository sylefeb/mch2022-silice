mch2022: BUILD_mch2022/build.bin program

program: BUILD_mch2022/build.bin prepare
	../common/webusb_fpga.py BUILD_mch2022/build.bin

BUILD_mch2022/build.bin: main.si prepare
	silice-make.py -s main.si -b mch2022 -p basic,lcd -o BUILD_mch2022

prepare:
	pushd . ; cd ../common ; ./download_all.sh ; popd

clean:
	rm -rf BUILD_*
