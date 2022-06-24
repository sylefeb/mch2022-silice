
mch2022: main.si
	silice-make.py -s main.si -b $@ -p basic,uart,lcd -o BUILD_$(subst :,_,$@)

verilator: main.si
	silice-make.py -s main.si -b $@ -p basic -o BUILD_$(subst :,_,$@)

icarus: main.si
	silice-make.py -s main.si -b $@ -p basic -o BUILD_$(subst :,_,$@)

clean:
	rm -rf BUILD_*
