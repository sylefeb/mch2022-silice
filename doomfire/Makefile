mch2022: clean BUILD_mch2022/build.bin program
	cp -f BUILD_mch2022/build.bin doomfire/bitstream.bin

program: BUILD_mch2022/build.bin prepare
	../common/ext/fpga.py BUILD_mch2022/build.bin

BUILD_mch2022/build.bin: main.si prepare
	silice-make.py -s main.si -b mch2022 -p basic,lcd -o BUILD_mch2022

prepare:
	pushd . ; cd ../common/ext ; ./download_all.sh ; popd

clean:
	rm -rf BUILD_*
