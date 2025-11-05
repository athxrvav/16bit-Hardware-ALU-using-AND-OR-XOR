#  16-Bit 4-Function ALU from Discrete Logic Gates

This project was developed as part of my semester coursework for the Digital Electronics subject. It significantly enhanced my understanding and strengthened my foundational knowledge of the discipline. For detailed report check: [Detailed Project Report (PDF)](/Detailed%20Report.pdf)

<img width="1134" height="454" alt="image" src="https://github.com/user-attachments/assets/4def3e11-5261-4b28-8770-b44be4f9761d" />




## 1. Overview

This project demonstrates the **design, simulation, and hardware implementation** of a 16-bit, 4-function Arithmetic Logic Unit (ALU).

The primary objective was to build the entire ALU from **first principles**, using only basic **74HC-series CMOS logic gate ICs** — with **no pre-integrated ALU or full-adder ICs**.  
The final product is a **fully functional 16-bit calculator** constructed and validated on breadboards.

---

## 2. Features

- **16-bit Operands:** Inputs A and B  
- **4 Arithmetic/Logic Operations:** selected via 2-bit control signal `S[1:0]`

| Control | Function | Description |
|----------|-----------|-------------|
| 00 | A AND B | Bitwise AND |
| 01 | A OR B | Bitwise OR |
| 10 | A + B | Addition |
| 11 | A - B | Subtraction (2’s complement) |

- **Modular 1-bit “ALU Slice”** replicated 16×  
- **Ripple-Carry Architecture** for arithmetic operations  
- **Verilog Structural Model** for simulation and schematic generation  

---

## 3. Hardware Design

The ALU is composed of **16 identical 1-bit slices**, connected in a **ripple-carry configuration**.

### 3.1 1-Bit ALU Slice

Each slice computes all four possible results for its input bits `(A_i, B_i)` simultaneously.  
A **4-to-1 multiplexer (74HC153)** selects the final result based on the global control `S[1:0]`.

**Parallel operations inside each slice:**
1. `A_i AND B_i`
2. `A_i OR B_i`
3. `A_i + B_i` (Sum)
4. `A_i - B_i` (Sum via two’s complement)

---

### 3.2 Unified Adder/Subtractor

A **single 16-bit ripple-carry adder** handles both addition and subtraction.

The trick: the least significant control bit `S[0]` is dual-purposed.

| Operation | S[0] | B_i XOR S[0] | Carry-In | Effective Operation |
|------------|------|--------------|-----------|----------------------|
| ADD (A + B) | 0 | B_i | 0 | `A + B` |
| SUB (A - B) | 1 | NOT B_i | 1 | `A + (NOT B) + 1` |

This implements subtraction perfectly using the **2’s complement formula**.

---

## 4. Operation Selection

| S[1] | S[0] | MUX Input | Function | Category |
|:----:|:----:|:----------:|:----------|:-----------|
| 0 | 0 | I₀ | A AND B | Logic |
| 0 | 1 | I₁ | A OR B | Logic |
| 1 | 0 | I₂ | A + B | Arithmetic |
| 1 | 1 | I₃ | A - B | Arithmetic |

All 8 MUX chips (74HC153) share the same global `S[1:0]` selector lines.

---

## 5. Hardware Bill of Materials (Approximate)

| IC (74HC-Series) | Function | Usage | Quantity |
|------------------|-----------|--------|----------:|
| 74HC08 | Quad 2-input AND | A AND B (4) + Adder logic (8) | 8 |
| 74HC32 | Quad 2-input OR | A OR B (4) + Adder logic (4) | 8 |
| 74HC86 | Quad 2-input XOR | B-Inverter (4) + Adder logic (8) | 12 |
| 74HC153 | Dual 4-to-1 MUX | Final result selection | 8 |

**Total:** ~36 ICs

**Additional components:**
- LEDs (Result + Inputs + Flags)
- 330 Ω resistors  
- DIP switches for A/B inputs  
- 5 V regulated supply  
- 0.1 µF ceramic decoupling capacitors (1 per IC)  
- Breadboards and wiring

---


## 6. Hardware Implementation Notes

-  **Decoupling is critical:** Place a 0.1 µF capacitor across Vcc–GND for each IC, as close as possible.  
-  **Build modularly:** Start with 1-bit, then 4-bit, and finally combine into the 16-bit ALU.  
-  **Carry chain:** Ensure `C_out(i)` connects **only** to `C_in(i+1)`.  
-  **Global control bus:** Lines `S[1]` and `S[0]` must connect to all slices in parallel.  

---

## 7. License

This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for details.

---

##  Future Work
- Add status flags (Zero, Negative, Overflow)
- Extend to 8-function ALU (Add XOR, NOR, etc.)
- Implement carry-lookahead for faster performance


