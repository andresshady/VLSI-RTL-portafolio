# Run all testbenches with Icarus Verilog (iverilog 11+):
#   make sim        -> every project
#   make iir        -> one project (led, acc, alu, iir, iir_check)
#   make clean
IVERILOG = iverilog -g2005 -Wall
BUILD    = build/sim

.PHONY: sim led acc alu iir iir_check clean

sim: led acc alu iir iir_check

$(BUILD):
	mkdir -p $(BUILD)

led: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/led.vvp 01-led-shifter-fpga/rtl/*.v 01-led-shifter-fpga/sim/xilinx_debug_stubs.v 01-led-shifter-fpga/tb/tb_top.v
	cd $(BUILD) && vvp -n led.vvp

acc: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/acc.vvp 02-accumulator/rtl/acc.v 02-accumulator/tb/tb_acc.v
	cd $(BUILD) && vvp -n acc.vvp

alu: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/alu.vvp 03-alu-4op/rtl/mux_op.v 03-alu-4op/tb/tb_mux_op.v
	cd $(BUILD) && vvp -n alu.vvp

iir: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/iir.vvp 05-iir-filter/rtl/iir_filter.v 05-iir-filter/tb/tb_iir_filter.v
	cd $(BUILD) && vvp -n iir.vvp

iir_check: | $(BUILD)
	$(IVERILOG) -o $(BUILD)/iir_check.vvp 05-iir-filter/rtl/iir_filter.v 05-iir-filter/tb/tb_iir_filter_autocheck.v
	cd $(BUILD) && vvp -n iir_check.vvp

clean:
	rm -rf build
