all : write read

write: write.si
	silice-make.py -s write.si -b mch2022 -p basic,uart,psram -o BUILD_$(subst :,_,$@)
	cp BUILD_write/build.bin bitstreams/write.bin

read: read.si
	silice-make.py -s read.si -b mch2022 -p basic,uart,psram -o BUILD_$(subst :,_,$@)
	cp BUILD_read/build.bin bitstreams/read.bin

clean:
	rm -rf BUILD_*
