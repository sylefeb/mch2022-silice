
write: write.si
	silice-make.py -s write.si -b mch2022 -p basic,uart,psram -o BUILD_$(subst :,_,$@)

read: read.si
	silice-make.py -s read.si -b mch2022 -p basic,uart,psram -o BUILD_$(subst :,_,$@)

clean:
	rm -rf BUILD_*
