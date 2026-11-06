# 01 · LED shifter on FPGA (Arty A7)

A one-hot pattern rotates across the four LEDs. A programmable counter sets the rotation speed, the switches control run/pause, speed and RGB color, and Vivado debug cores let the design be driven and observed from the PC while it runs on the board.

## Architecture

```
             ┌───────────┐ o_valid ┌────────────┐
i_sw[2:0] ──▶│   count   │────────▶│  shiftreg  │──▶ o_led[3:0] ──▶ RGB color logic ──▶ o_led_g, o_led_b
             └───────────┘         └────────────┘
```

Switches and reset come from the board or from the VIO (selected by `selmux`); the ILA probes the LED pattern.

| Module | Function |
|--------|----------|
| `count` | Counts while `i_sw[0] = 1`; when it reaches the limit selected by `i_sw[2:1]` it restarts and pulses `o_valid` for one cycle. Asynchronous reset. |
| `shiftreg` | One-hot register, resets to `0001` and rotates left on every `o_valid` pulse. Synchronous reset. |
| `top` | Connects both blocks, the RGB color logic and the ILA/VIO cores. A VIO output (`selmux`) switches the inputs between the board and the VIO. |

## Interface

| Port | Dir | Description |
|------|-----|-------------|
| `clock` | in | 100 MHz board clock |
| `i_reset` | in | Reset, active low (CK_RST button) |
| `i_sw[0]` | in | Run (1) / pause (0) |
| `i_sw[2:1]` | in | Shift period: R0, R1, R2 or R3 |
| `i_sw[3]` | in | Blue RGB LEDs show the pattern when 0 |
| `o_led[3:0]` | out | Shift register pattern (LD4–LD7) |
| `o_led_g[3:0]`, `o_led_b[3:0]` | out | Green and blue channels of the RGB LEDs (green follows `i_sw[2]`) |

With `NB_COUNTER = 32` and a 100 MHz clock, the shift period is 2^22, 2^23, 2^24 or 2^25 cycles: about 42, 84, 168 or 336 ms.

## Verification

- `tb/tb_top.v`: directed testbench with `NB_COUNTER = 12` so the rotation is visible in a short simulation; steps through the run, speed and color settings.
- `sim/xilinx_debug_stubs.v`: empty ILA/VIO models so the testbench runs in any simulator (`make led`).
- On the board: ILA captures the LED pattern and VIO overrides switches and reset from Vivado Hardware Manager.

## Files

| Path | Content |
|------|---------|
| `rtl/` | `top.v`, `count.v`, `shiftreg.v` |
| `tb/` | `tb_top.v` |
| `sim/` | ILA/VIO simulation stubs (not for synthesis) |
| `constraints/` | `arty_a7_led_shifter.xdc` |
| `ip/` | `ILA.bd` (ILA 6.2) and `VIO.bd` (VIO 3.0) block designs |
