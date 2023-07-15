# QPI-PSRAM writer and loader

This tool is used to store data from UART into PSRAM (external RAM accessible with the SPI protocol). 
Typically this would be used to put data in PSRAM before switching to a design that expects this data
to be there. As long as the badge has power, the written data remains in SPRAM.

To build the writer, run
```make write```

Program the FPGA with
```../common/ext/fpga.py BUILD_write/build.bin```

To send data, run
```python send.py <uart port> 0 <file>``` where `<uart port>` is typically `/dev/ttyACM1` under Linux and e.g. `COM6` under Windows.

___

To build the reader, run
```make read```

Program the FPGA with
```../common/ext/fpga.py BUILD_read/build.bin```

To read data, run
```python get.py <uart port> 0``` where `<uart port>` is typically `/dev/ttyACM1` under Linux and e.g. `COM6` under Windows.
