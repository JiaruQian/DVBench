## F-AP-001

**requirement_ids**: ["R-dv-014-ap3216c-sensor-001"]

**module**: ap3216c_top

**definition**: sys_rst_n is asynchronous and active low. After reset, the I2C clock and the master's SDA drive are both high, led=0000, sel=111111, and seg_led=C0. Reset interrupts polling in progress, and initialization restarts after release; no data guarantee is made for the ALS display value before the first complete publication, and a legal design must not be rejected based on this undefined domain.

**interface**: ["sys_clk", "sys_rst_n", "ap_scl", "ap_sda", "led", "sel", "seg_led"]

**timing**: Use the default 50MHz system clock and sample after the native outputs have stabilized; allow conversion/scanning waits to elapse naturally.

**boundary**: Keep the default parameters fixed, with no acceleration using force/internal probes; display data is not guaranteed before the first complete ALS publication.

## F-AP-002

**requirement_ids**: ["R-dv-014-ap3216c-sensor-002"]

**module**: ap3216c_top

**definition**: Fix sys_clk=50MHz, CLK_FREQ=50000000, and I2C_FREQ=250000. I2C operations use a 1MHz internal time tick, and the master holds each data bit for four ticks, transmitting MSB first; SDA changes during the low phase of SCL and is stable during the high phase, except for START and STOP. SCL clock stretching and multi-master arbitration are not supported.

**interface**: ["sys_clk", "ap_scl", "ap_sda"]

**timing**: Use the default 50MHz system clock and sample after the native outputs have stabilized; allow conversion/scanning waits to elapse naturally.

**boundary**: Keep the default parameters fixed, with no acceleration using force/internal probes; display data is not guaranteed before the first complete ALS publication.

## F-AP-003

**requirement_ids**: ["R-dv-014-ap3216c-sensor-003"]

**module**: ap3216c_top

**definition**: After each reset release, the master waits for the startup delay, then issues a write transaction to 7-bit address 1E, sending 8-bit register address 00 and data 03. The first START occurs on the 105th rising edge of the operation time tick after release; clock division restarts from the count cleared at reset. The configuration write occurs only once after reset.

**interface**: ["sys_clk", "sys_rst_n", "ap_scl", "ap_sda"]

**timing**: Use the default 50MHz system clock and sample after the native outputs have stabilized; allow conversion/scanning waits to elapse naturally.

**boundary**: Keep the default parameters fixed, with no acceleration using force/internal probes; display data is not guaranteed before the first complete ALS publication.

## F-AP-004

**requirement_ids**: ["R-dv-014-ap3216c-sensor-004"]

**module**: ap3216c_top

**definition**: After initialization, loop indefinitely, reading one byte each in the order 0E, 0F, 0C, 0D. Each read first writes the device address and 8-bit register address, then issues a repeated START and the device read address, receives 8 bits, and then sends a high-level non-acknowledgment and STOP. The interval from the SDA rising edge of the preceding STOP to the next START is: 12519 operation ticks after the configuration write or a 0D read; 21 operation ticks after a 0E or 0C read; and 100019 operation ticks after a 0F read. The complete top level must not be reduced to a standalone display or I2C submodule.

**interface**: ["sys_clk", "ap_scl", "ap_sda"]

**timing**: Use the default 50MHz system clock and sample after the native outputs have stabilized; allow conversion/scanning waits to elapse naturally.

**boundary**: Keep the default parameters fixed, with no acceleration using force/internal probes; display data is not guaranteed before the first complete ALS publication.

## F-AP-005

**requirement_ids**: ["R-dv-014-ap3216c-sensor-005"]

**module**: ap3216c_top

**definition**: The master actively drives 0 or 1 when transmitting bits and non-acknowledgments; when receiving slave ACKs and data, it releases SDA, with the external pull-up and slave pull-down forming the input. A high ACK level does not terminate subsequent bytes, STOP, or polling. The external sensor must drive only during receive windows in which the master releases the line, keeping data stable before sampling; a high level on the master's ap_sda is not synonymous with open-drain release.

**interface**: ["ap_scl", "ap_sda"]

**timing**: Use the default 50MHz system clock and sample after the native outputs have stabilized; allow conversion/scanning waits to elapse naturally.

**boundary**: Keep the default parameters fixed, with no acceleration using force/internal probes; display data is not guaranteed before the first complete ALS publication.

## F-AP-006

**requirement_ids**: ["R-dv-014-ap3216c-sensor-006"]

**module**: ap3216c_top

**definition**: The lower 4 bits of the byte received from 0E become the lower 4 bits of the PS value, and the lower 6 bits of the byte received from 0F become the upper 6 bits. Bits 6 and 7 in the two bytes do not inhibit data publication. This 10-bit value is published 100015 operation ticks after the STOP of the 0F transaction, and the LED updates one operation tick later. The LED is 0001 when PS is less than 16, 0011 for 16 to 127, 0111 for 128 to 511, and 1111 for 512 to 1023; before the first PS publication, outside reset, display 0001 according to PS=0.

**interface**: ["ap_scl", "ap_sda", "led"]

**timing**: Use the default 50MHz system clock and sample after the native outputs have stabilized; allow conversion/scanning waits to elapse naturally.

**boundary**: Keep the default parameters fixed, with no acceleration using force/internal probes; display data is not guaranteed before the first complete ALS publication.

## F-AP-007

**requirement_ids**: ["R-dv-014-ap3216c-sensor-007"]

**module**: ap3216c_top

**definition**: The 0C byte is the low byte of the raw ALS value, and the 0D byte is the high byte. Publish the converted value 14 operation ticks after the STOP of the 0D transaction: first multiply the unsigned 16-bit raw value by 35, truncate the product to 16 bits, then divide by 100 and round toward zero. Thus the result ranges from 0 to 655; for example, raw value 30000 yields 14, and 65535 yields 655. Retain the previous value between two complete publications; receiving only the low byte does not change the published value; the data meaning of the segment code is undefined before the first complete publication.

**interface**: ["ap_scl", "ap_sda", "seg_led"]

**timing**: Use the default 50MHz system clock and sample after the native outputs have stabilized; allow conversion/scanning waits to elapse naturally.

**boundary**: Keep the default parameters fixed, with no acceleration using force/internal probes; display data is not guaranteed before the first complete ALS publication.

## F-AP-008

**requirement_ids**: ["R-dv-014-ap3216c-sensor-008"]

**module**: ap3216c_top

**definition**: Display the published ALS converted value as a decimal number, with the lowest digit at the lowest bit of sel; leave higher leading-zero positions blank, and display a single 0 for the value 0. There is no minus sign, and all decimal points are off. The eight-bit active-low segment codes for 0 through 9 are, in order, C0, F9, A4, B0, 99, 92, 82, F8, 80, 90; blank is FF.

**interface**: ["sel", "seg_led"]

**timing**: Use the default 50MHz system clock and sample after the native outputs have stabilized; allow conversion/scanning waits to elapse naturally.

**boundary**: Keep the default parameters fixed, with no acceleration using force/internal probes; display data is not guaranteed before the first complete ALS publication.

## F-AP-009

**requirement_ids**: ["R-dv-014-ap3216c-sensor-009"]

**module**: ap3216c_top

**definition**: The display time tick is sys_clk divided by ten, with a high reset phase. The six digit-select patterns cycle through 111110, 111101, 111011, 110111, 101111, 011111; advance the scan position every 5000 display rising edges, with the new digit select occurring one additional display rising edge after the position advances due to the register pipeline. Decimal conversion, current-digit selection, and segment-code encoding each use the values registered on the preceding display edge; allow this fixed pipeline to propagate after a new ALS value appears. Scanning of sel is independent of whether the first ALS data is valid.

**interface**: ["sys_clk", "sys_rst_n", "sel", "seg_led"]

**timing**: Use the default 50MHz system clock and sample after the native outputs have stabilized; allow conversion/scanning waits to elapse naturally.

**boundary**: Keep the default parameters fixed, with no acceleration using force/internal probes; display data is not guaranteed before the first complete ALS publication.
