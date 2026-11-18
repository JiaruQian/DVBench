# alarm_clock_top

A fixed version of a four-digit ASCII clock. All inputs are two-state; key ranges from 0 to 10. Keys and buttons may be combined arbitrarily. All register updates occur on the rising edge of clock; reset is active-high and asynchronous. Time starts at 00:00.

### R-dv-034-001 — Reset

After reset is asserted, without waiting for a rising edge of clock, all four display outputs are ASCII 0 (0x30), and alarm_sound is 1. This remains true while reset is held; deassertion does not advance time.

### R-dv-034-002 — Tick

Rising edges after reset deassertion are counted starting from 1; when fastwatch=0, a minute-advance enable is generated every 15360 cycles, time first increments by one minute on cycle 15361, and then increments by one every 15360 cycles. When fastwatch=1, the first increment occurs on cycle 257, followed by one increment every 256 cycles.

### R-dv-034-003 — Calendar Wraparound

Each minute advance increments the time by one minute in 24-hour format, from 00:09 to 00:10, from 00:59 to 01:00, from 09:59 to 10:00, and from 23:59 to 00:00; each of the four decimal digits outputs 0x30 plus that digit's value.

### R-dv-034-004 — Key Isolation

In this fixed version, key, time_button, and alarm_button do not set the current time or alarm, nor do they change the display source; under any legal history of these inputs, the display remains the current running time, and the alarm is fixed at 00:00.

### R-dv-034-005 — Speed Switching and Alarm Sounding

fastwatch combinationally selects the existing normal or fast enable; switching does not reset the timing phase. alarm_sound is 1 if and only if the current time is 00:00, including reset and full-day wraparound; it is 0 during all other minutes.

