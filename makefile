SIM = sim/riscv_sim
VCD = sim/dump.vcd

all: $(SIM)
	vvp $(SIM)

$(SIM):
	iverilog -o $(SIM) \
		rtl/alu.v rtl/reg_file.v rtl/imm_gen.v \
		rtl/control_unit.v rtl/imem.v rtl/dmem.v \
		rtl/riscv_core.v rtl/uart_tx.v rtl/uart_rx.v \
		rtl/soc_top.v tb/tb_riscv_core.v

wave:
	gtkwave $(VCD)

clean:
	rm -f $(SIM) $(VCD)

