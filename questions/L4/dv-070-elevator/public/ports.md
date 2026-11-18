# top_module Native Port Contract

All ports are unsigned. packed range preserves the native index direction; scalar is 1 bit. Only declaration information is provided; the hidden DUT is compiled and connected by the service.

| Port | Direction | packed range |
|---|---|---|
| `clk` | input | `scalar` |
| `rst` | input | `scalar` |
| `floor_0_p` | input | `scalar` |
| `floor_1_p` | input | `scalar` |
| `floor_2_p` | input | `scalar` |
| `floor_3_p` | input | `scalar` |
| `floor_4_p` | input | `scalar` |
| `direction_1` | input | `scalar` |
| `direction_2` | input | `scalar` |
| `direction_3` | input | `scalar` |
| `floor_0_d` | input | `scalar` |
| `floor_1_d` | input | `scalar` |
| `floor_2_d` | input | `scalar` |
| `floor_3_d` | input | `scalar` |
| `floor_4_d` | input | `scalar` |
| `led_inside_0` | output | `scalar` |
| `led_inside_1` | output | `scalar` |
| `led_inside_2` | output | `scalar` |
| `led_inside_3` | output | `scalar` |
| `led_inside_4` | output | `scalar` |
| `led_outside_0` | output | `scalar` |
| `led_outside_1` | output | `scalar` |
| `led_outside_2` | output | `scalar` |
| `led_outside_3` | output | `scalar` |
| `led_outside_4` | output | `scalar` |
| `led_busy` | output | `scalar` |
| `a_out` | output | `scalar` |
| `b_out` | output | `scalar` |
| `c_out` | output | `scalar` |
| `d_out` | output | `scalar` |
| `e_out` | output | `scalar` |
| `f_out` | output | `scalar` |
| `g_out` | output | `scalar` |
| `p_out` | output | `scalar` |
| `an` | output | `[7:0]` |

Top-level parameter defaults: there are no overridable top-level parameters. Overrides are not allowed in this task.

Instantiate the real DUT using the ports above; do not define a module with the same name or list an empty stub in sources.f. The independent prediction model dvbench_model uses exactly the same port names, directions, and bit widths.
