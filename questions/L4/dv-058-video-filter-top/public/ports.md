# Native interface and fixed parameters

Top level video_filter_top; model entry point dvbench_model; preserve port names, directions, widths, and index directions.

|Port|Direction|Width|Index|
|---|---|---|---|
|btn|In|4|[{'kind': 'packed', 'left': 3, 'right': 0}]|
|clk|In|1|[]|
|i_vid_VDE|In|1|[]|
|i_vid_data|In|24|[{'kind': 'packed', 'left': 23, 'right': 0}]|
|i_vid_hsync|In|1|[]|
|i_vid_vsync|In|1|[]|
|led|Out|4|[{'kind': 'packed', 'left': 3, 'right': 0}]|
|n_rst|In|1|[]|
|o_vid_VDE|Out|1|[]|
|o_vid_data|Out|24|[{'kind': 'packed', 'left': 23, 'right': 0}]|
|o_vid_hsync|Out|1|[]|
|o_vid_vsync|Out|1|[]|
|sw|In|4|[{'kind': 'packed', 'left': 3, 'right': 0}]|

## Native parameter defaults

- DATA_WIDTH = 24
- IMAGE_WIDTH = 1920
- IMAGE_HEIGHT = 1080
- BLINK_RATE = 26'd62500000
- DEBOUNCE_LIMIT = 22'd2500000


## Fixed configuration for this task

Fixed DATA_WIDTH=24, IMAGE_WIDTH=384, IMAGE_HEIGHT=64, BLINK_RATE=6, DEBOUNCE_LIMIT=2500000. The subfilters still use the hardcoded 2500000 sampling period.
