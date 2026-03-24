# RISC-V + UART SoC — Sky130

A single-cycle RV32I processor integrated with UART TX/RX, synthesized to GDS using OpenLane on the SkyWater 130nm open-source PDK.

The chip runs an assembly program that transmits **"MRIDUL"** over a serial interface.

---

## Block Diagram

```
         ┌─────────────────────────────────────────┐
         │              soc_top                    │
         │                                         │
clk  ───►│  ┌──────────────┐   ┌───────────────┐  │───► tx
rst_n───►│  │  riscv_core  │──►│   uart_tx     │  │
rx   ───►│  │              │   └───────────────┘  │
         │  │  RV32I       │                       │
         │  │  Single Cycle│   ┌───────────────┐  │
         │  │              │◄──│   uart_rx     │  │
         │  └──────────────┘   └───────────────┘  │
         └─────────────────────────────────────────┘
```

---

## Features

- **RV32I Single Cycle Core** — ALU, Register File, Control Unit, ImmGen, IMEM, DMEM
- **UART TX** — 9600 baud, 8N1, 50MHz clock (BAUD_DIV = 5208)
- **UART RX** — Center-sampling, FSM-based receiver
- **SoC Integration** — Core drives UART via `x10 (a0)` and `x11 (a1)` registers
- **Verified Instructions** — ADDI, ADD, LW, SW, BEQ
- **RTL to GDS** — OpenLane on Sky130 PDK
- **DRC/LVS/Antenna** — All clean 

---

## Chip Pins

| Pin     | Direction | Description                      |
|---------|-----------|----------------------------------|
| `clk`   | Input     | 50MHz clock                      |
| `rst_n` | Input     | Active-low reset                 |
| `rx`    | Input     | UART receive pin                 |
| `tx`    | Output    | UART transmit — outputs "MRIDUL" |

---

## Post-Implementation Results

| Metric                | Value                     |
|-----------------------|---------------------------|
| Flow Status           | Successful                |
| Synth Cell Count      | 375                       |
| Total Cells (w/ fill) | 1350                      |
| Die Area              | 13,822 um² (0.0138 mm²)   |
| Core Area             | 10,184.8 um²              |
| Core Utilization      | 42.15%                    |
| Critical Path         | 2.43 ns                   |
| Fmax (STA)            | ~411 MHz                  |
| Operating Frequency   | 50 MHz                    |
| Setup Slack           | 17.57 ns                  |
| WNS                   | 0.00 ns                   |
| TNS                   | 0.00 ns                   |
| Total Power           | 0.639 mW                  |
| Sequential Power      | 0.269 mW (42.1%)          |
| Combinational Power   | 0.370 mW (57.9%)          |
| Vias                  | 8458                      |
| DRC Violations        | 0                         |
| LVS Status            | Clean                     |
| Antenna Violations    | 0                         |

---

## Project Structure

```
riscv_project/
├── rtl/
│   ├── alu.v              ALU — ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, SRA
│   ├── reg_file.v         32 x 32-bit register file
│   ├── imm_gen.v          Immediate generator (I, S, B, U, J types)
│   ├── control_unit.v     Instruction decoder — opcode to control signals
│   ├── imem.v             Instruction memory (ROM, 256 words)
│   ├── dmem.v             Data memory (RAM, 256 words)
│   ├── riscv_core.v       Top-level core — all modules wired together
│   ├── uart_tx.v          UART transmitter (9600 baud)
│   ├── uart_rx.v          UART receiver (9600 baud)
│   └── soc_top.v          SoC top — core + UART TX/RX
├── tb/
│   └── tb_riscv_core.v    Testbench
├── sim/                   Simulation output (VCD)
├── program.hex            Assembly program (MRIDUL transmit)
└── Makefile
```

---

## How It Works

### RISC-V Core

The core is single-cycle — every instruction completes in one clock cycle. The datapath has five stages (Fetch, Decode, Execute, Memory, Writeback) all happening combinationally within one cycle, with only the PC and register file being sequential.

The control unit decodes the opcode and generates signals like `reg_we`, `alu_src`, `mem_to_reg`, and `alu_ctrl`. These signals tell every other module what to do for that instruction.

### UART Interface

Instead of a memory-mapped peripheral bus, a simpler approach was used — two registers are wired directly to UART:

- `x10 (a0)` → `uart_data` — the byte to transmit
- `x11 (a1)` → `uart_start` — a pulse to trigger transmission

The assembly program loads each ASCII character into `x10` and pulses `x11`:

```asm
addi x10, x0, 77    # 'M'
addi x11, x0, 1     # start = 1
addi x11, x0, 0     # start = 0 (pulse done)
addi x10, x0, 82    # 'R'
...
```

### UART TX

UART transmits at 9600 baud. At 50MHz clock, each bit lasts 5208 cycles (`BAUD_DIV = 50_000_000 / 9600`). When `start` pulses high, the byte is loaded into a shift register as `{stop_bit, data[7:0], start_bit}` and shifted out LSB-first over the `tx` pin.

### UART RX

The receiver uses a 4-state FSM — IDLE, START, DATA, STOP. On detecting a falling edge (start bit), it waits `HALF_BAUD` cycles to sample at the center of each bit, which avoids edge noise. After 8 data bits, it asserts `valid` with `data_out` ready.

---

## Simulation

### Requirements

```bash
sudo apt install iverilog gtkwave
```

### Run

```bash
make          # compile and simulate
make wave     # open GTKWave
make clean
```

### Expected Output

```
uart_data=77 (M) | start=1
uart_data=82 (R) | start=1
uart_data=73 (I) | start=1
uart_data=68 (D) | start=1
uart_data=85 (U) | start=1
uart_data=76 (L) | start=1
```

### Instructions Verified

| Instruction | Test                    | Result |
|-------------|-------------------------|--------|
| `ADDI`      | `x1 = x0 + 5` → x1=5   | ✅     |
| `ADD`       | `x3 = x1 + x2` → x3=15 | ✅     |
| `SW`        | store x3 to memory      | ✅     |
| `LW`        | load back → x4=15       | ✅     |
| `BEQ`       | branch loop             | ✅     |

---

## RTL to GDS

The design was taken through the full OpenLane flow — synthesis with Yosys, floorplan, placement, clock tree synthesis, routing with TritonRoute, and signoff with Magic DRC, Netgen LVS, and OpenSTA.

Die area was set to 600×600 micron with 40% core utilization. Total flow runtime was 1 minute 21 seconds.

### Run

```bash
mkdir -p ~/OpenLane/designs/riscv_uart_soc/src
cp rtl/*.v ~/OpenLane/designs/riscv_uart_soc/src/

cd ~/OpenLane
make mount

# inside container
./flow.tcl -design riscv_uart_soc
```

### Signoff Results

```
Magic DRC  : 0 violations  
LVS        : clean (482 nets)  
Antenna    : 0 violations  
```

---

## Tools

| Tool           | Purpose               |
|----------------|-----------------------|
| Icarus Verilog | RTL simulation        |
| GTKWave        | Waveform viewer       |
| OpenLane       | RTL to GDS flow       |
| Sky130 PDK     | Process design kit    |
| KLayout        | GDS viewer            |
| Magic          | DRC / LVS             |
| Yosys          | Synthesis             |
| OpenROAD       | Placement and routing |

---

Mridul Mor 