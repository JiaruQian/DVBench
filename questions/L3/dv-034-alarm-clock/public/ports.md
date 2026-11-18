# Native Interface

Top level `alarm_clock_top`, model top level `dvbench_model`. Fixed parameters use default values:

{}

| Name | Direction | Bit width | Index |
|---|---|---|---|
| alarm_button | In | 1 | [] |
| alarm_sound | Out | 1 | [] |
| clock | In | 1 | [] |
| fastwatch | In | 1 | [] |
| key | In | 4 | [{'kind': 'packed', 'left': 3, 'right': 0}] |
| ls_hour | Out | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| ls_minute | Out | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| ms_hour | Out | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| ms_minute | Out | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| reset | In | 1 | [] |
| time_button | In | 1 | [] |
