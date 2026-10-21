# ALU_Digital_Design
8-Bit Combinational vs. 2-Stage Pipelined ALU in Verilog (Vivado STA &amp; Throughput Optimization)
# Parameterized RTL ALU & 2-Stage Pipelined Architecture Optimization

An 8-bit parameterized Arithmetic Logic Unit (ALU) designed in Verilog HDL, verified via self-checking testbenches, and synthesized using AMD Vivado for Xilinx FPGA target logic. This repository features both a single-cycle **Combinational ALU** baseline and an optimized **2-Stage Pipelined ALU** designed to maximize operational frequency (**F_max**).

---

## Key Performance & Utilization Metrics

| Design Parameter | Combinational ALU | 2-Stage Pipelined ALU | Architectural Impact |
| :--- | :--- | :--- | :--- |
| **Logic Slices (LUTs)** | 66 LUTs | 80 LUTs | +14 LUTs (+21% area for pipeline stage MUXes) |
| **Flip-Flops (Registers)** | 0 FFs | 73 FFs | Added stage registers (`reg_add_sub`, `reg_alu_sel`, etc.) |
| **I/O Pins** | 31 Pins | 33 Pins | +2 Pins (`clk` & `rst` synchronous lines) |
| **Global Clock Buffers** | 0 BUFG | 1 BUFGCTRL | Low-skew clock tree routing allocated |
| **Critical Delay (T_pd)** | **6.904 ns** | **3.410 ns** | **50.6% reduction in critical path delay** |
| **Max Frequency (F_max)** | **~144.8 MHz** | **~293.3 MHz** | **102.5% throughput increase (2.03x speedup)** |

---

## Architectural Highlights

### 1. Baseline Combinational ALU
* Supports 8 arithmetic (ADD, SUB), bitwise (AND, OR, XOR, NOR), and shift (ASR, LSL) operations.
* Formulated status flags: `Zero` (Z), `Negative` (N), `CarryOut` (C), and Signed `Overflow` (V).
* Static Timing Analysis (STA) identified the **8-bit NOR-reduction Zero flag path** (`A[0] -> Zero`) across 8 logic levels as the primary timing bottleneck (6.904 ns delay).

### 2. 2-Stage Pipelined Optimization
* **Stage 1 (Combinational Compute):** Computes arithmetic, bitwise, and shifter outputs in parallel and latches results into pipeline registers on `posedge clk`.
* **Stage 2 (MUXing & Flag Generation):** Multiplexes stage outputs using pipelined control signals (`reg_alu_sel`) and generates status flags.
* **Result:** Successfully split the critical path logic depth in half, boosting clock frequency from **144.8 MHz to 293.3 MHz**.

---

## Verification Strategy
* **Combinational:** Self-checking testbench asserting flag responses and boundary conditions.
* **Pipelined:** Synchronous testbench driving inputs on clock edges and evaluating output vectors across a 1-cycle pipeline latency.
