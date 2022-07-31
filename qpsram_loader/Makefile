all : write read stream

write: write.si prepare
	silice-make.py -s write.si -b mch2022 -p basic,uart,psram -o BUILD_$(subst :,_,$@)
	cp BUILD_write/build.bin bitstreams/write.bin

read: read.si prepare
	silice-make.py -s read.si -b mch2022 -p basic,uart,psram -o BUILD_$(subst :,_,$@)
	cp BUILD_read/build.bin bitstreams/read.bin

stream: stream.si prepare
	silice-make.py -s stream.si -b mch2022 -p basic,uart,psram -o BUILD_$(subst :,_,$@)
	../common/ext/webusb_fpga.py BUILD_stream/build.bin

simulation: simul.si prepare
	silice-make.py -s simul.si -b icarus -p basic -o BUILD_$(subst :,_,$@)

prepare:
	pushd . ; cd ../common/ext ; ./download_all.sh ; popd

clean:
	rm -rf BUILD_*
