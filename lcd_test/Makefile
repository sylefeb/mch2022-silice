mch2022: BUILD_mch2022/build.bin prepare program

program: BUILD_mch2022/build.bin
	../common/webusb_fpga.py BUILD_mch2022/build.bin

BUILD_mch2022/build.bin: main.si
	silice-make.py -s main.si -b mch2022 -p basic,uart,lcd -o BUILD_mch2022

prepare:
	pushd . ; cd ../common ; ./download_all.sh ; popd

clean:
	rm -rf BUILD_*
