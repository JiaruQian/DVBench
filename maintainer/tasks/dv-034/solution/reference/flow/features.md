## F-001
requirement_ids: R-dv-034-001
module: alarm_clock_top
definition: After reset is asserted, without waiting for a rising edge of clock, all four display outputs are ASCII 0 (0x30), and alarm_sound is 1. This remains true while reset is held; deassertion does not advance time.
interface: reset, clock, ms_hour, ls_hour, ms_minute, ls_minute, alarm_sound
timing: Timing conditions, delays, and valid windows are as stated in this item's definition.
boundary: Use the public legal inputs and fixed parameters; see definition for all boundaries.

## F-002
requirement_ids: R-dv-034-002
module: alarm_clock_top
definition: Rising edges after reset deassertion are counted starting from 1; when fastwatch=0, a minute-advance enable is generated every 15360 cycles, time first increments by one minute on cycle 15361, and then increments by one every 15360 cycles. When fastwatch=1, the first increment occurs on cycle 257, followed by one increment every 256 cycles.
interface: clock, reset, fastwatch, ms_hour, ls_hour, ms_minute, ls_minute
timing: Timing conditions, delays, and valid windows are as stated in this item's definition.
boundary: Use the public legal inputs and fixed parameters; see definition for all boundaries.

## F-003
requirement_ids: R-dv-034-003
module: alarm_clock_top
definition: Each minute advance increments the time by one minute in 24-hour format, from 00:09 to 00:10, from 00:59 to 01:00, from 09:59 to 10:00, and from 23:59 to 00:00; each of the four decimal digits outputs 0x30 plus that digit's value.
interface: clock, reset, fastwatch, ms_hour, ls_hour, ms_minute, ls_minute
timing: Timing conditions, delays, and valid windows are as stated in this item's definition.
boundary: Use the public legal inputs and fixed parameters; see definition for all boundaries.

## F-004
requirement_ids: R-dv-034-004
module: alarm_clock_top
definition: In this fixed version, key, time_button, and alarm_button do not set the current time or alarm, nor do they change the display source; under any legal history of these inputs, the display remains the current running time, and the alarm is fixed at 00:00.
interface: key, time_button, alarm_button, clock, reset, ms_hour, ls_hour, ms_minute, ls_minute, alarm_sound
timing: Timing conditions, delays, and valid windows are as stated in this item's definition.
boundary: Use the public legal inputs and fixed parameters; see definition for all boundaries.

## F-005
requirement_ids: R-dv-034-005
module: alarm_clock_top
definition: fastwatch combinationally selects the existing normal or fast enable; switching does not reset the timing phase. alarm_sound is 1 if and only if the current time is 00:00, including during reset and full-day wraparound; it is 0 for all other minutes.
interface: fastwatch, clock, reset, ms_hour, ls_hour, ms_minute, ls_minute, alarm_sound
timing: Timing conditions, delays, and valid windows are as stated in this item's definition.
boundary: Use the public legal inputs and fixed parameters; see definition for all boundaries.
