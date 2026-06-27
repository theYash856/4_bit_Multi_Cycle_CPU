# 4-bit CPU

## 1. Motivation 
In order to understand the theory of combinational and sequential circuits practically, I previously built the [4-bit ALU](https://github.com/theYash856/4_bit_ALU) and [4-Floor Elevator Controller](https://github.com/theYash856/4_Floor_Elevator_Controller) projects respectively.

Having completed the standard Digital System Design (DSD) concepts, I wanted to move beyond individual modules and understand how different digital components work together to form a complete processor. This led to the development of a 4-bit CPU as the culminating project.

The objective of this project is not just to implement a CPU in Verilog, but also to understand the fundamentals of Computer Organisation & Architecture (COA), like memory organisation, different types of registers and their functions, control logic and the fetch-decode-execute cycle through practical implementation.

## 4. CPU Specifications

| Parameter | Specification |
|:----------:|:-----------:|
| Architecture | Von Neumann Architecture |
| Datapath Width | 4 bits |
| Instruction Width | 12 bits |
| Register File | 4 General Purpose Registers (R0-R3)|
| Memory Organisation | Unified Instruction and Data Memory |
| Memory Size | 16 x 12-bit |
| Program Counter Width | 4 bits |

## 7. Individiual Module Design 

### A. Program Counter (PC)
#### Purpose
It acts as the CPU's position tracker. It stores the address of the next instruction to be executed. 

#### Operation
- It resets to 0 if `rst` is 1.
- Increments by 1 on every clock cycle.
- Loads the `jump_address` during `jump` signal.
- Provides the current address to the memory.

### B. Register File 
#### Purpose 
It acts as the CPU's internal memory. It stores the operands required by the ALU as well as the computed results.

#### Operation
- Contains 4 General Purpose Registers (R0-R3).
- The registers can act as both source and destination registers depending on the instruction being executed.
- The `write_enable` signal writes the data only when it is 1, otherwise the previous value is retained.
- If `rst` is 1, all the registers are cleared to `0000`.
- Supports two simultaneous combinational reads (operand A and operand B) to feed the ALU in the same cycle.

### C. Main Memory

