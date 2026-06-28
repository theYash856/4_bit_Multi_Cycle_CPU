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

## 5. Instruction Set Architecture (ISA)
The ISA supports 16 operations out of which, first 12 are ALU operations and last 4 are CPU operations. The instruction descriptions are written using Register Transfer Language (RTL).
**Rd** - Destination Register
**Rs** - Source Register
| Opcode | Operation | Description |
|:-------:|:---------:|:----------:|
| 0000| AND | Rd ← Rd AND Rs | 
| 0001| OR | Rd ← Rd OR Rs |
| 0010 | NOT | Rd ← ~Rd |
| 0011 | XOR | Rd ← Rd XOR Rs |
| 0100| ADD | Rd ← Rd + Rs |
| 0101| SUB | Rd ← Rd - Rs |
| 0110| SLL | Rd ← Rd << 1|
| 0111| SRL | Rd ← Rd >> 1|
| 1000| SEQ | Rd ← (Rd == Rs)|
|1001| SLT | Rd ← (Rd < Rs)|
|1010| SGT | Rd ← (Rd > Rs)|
|1011| INC | Rd ← Rd + 1 |
|1100| LOAD | Read data from memory |
|1101| STORE | Write data into memory |
|1110| JUMP | Jumps to target address |
|1111| HALT | Stops CPU execution|


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

### D. Instruction Register (IR)
#### Purpose

IR stores the fetched instruction temporarily so that it can be decoded and executed during subsequent clock cycles. Without the IR, the instruction would be lost once the Program Counter advances to the next address.

#### Operation

- The instruction from memory is loaded into the IR during the `FETCH` stage.
- The stored instruction is then used by the Control Unit and datapath during `DECODE` and `EXECUTE` stages.
- The instruction remains unchanged until a new instruction is fetched or the register is reset.

### E. Control Unit (CU)
#### Purpose
It is the brain of the CPU. All the logic decisions are taken in this section. The CPU follows a multi-cycle execution model:

`FETCH` → `DECODE` → `EXECUTE` → `WRITEBACK` → `FETCH`
#### Operation
**1. FETCH State**
- Loads the next instruction from the memory into the Instruction Register.
- Activates the `ir_load` signal.

**2. DECODE State**
- Decodes the instruction opcode and instruction fields.
- Determines the type of instruction being executed.
- No control signals are triggered as the decoding is performed internally.

**3. EXECUTE State**

The instruction performed depends on the `opcode`:
- ALU instructions enable the ALU and pass the `opcode` as `alu_op`.
- LOAD instructions activate the `mem_read` signal to read from memory.
- STORE instructions activate the `mem_write` signal to write into the memory.
- JUMP instructions activate the `jump_enable` signal.
- HALT instructions generate the `halt` signal which pauses the execution.

**4. WRITEBACK State**

Similar to `EXECUTE` state, the `opcode` determines the operation:
- ALU instructions write the ALU result back to the register file via `reg_write` signal.
- LOAD instructions write the memory data back to the destination register using `reg_write` and `mem_to_reg`.
- The Program Counter is updated to fetch the next instruction after the cycle completes.
- HALT instructions prevent further PC updates.
- STORE and JUMP instructions are left idle as their functions are completed in `EXECUTE` state.

#### Design Decisions
- Initially, the CPU executed the entire Fetch-Decode-Execute cycle within a single clock cycle. This made the FSM unnecessary. In order to incorporate the multi-cycle functionality to make the CPU practical, `FETCH`, `DECODE`, `EXECUTE` and `WRITEBACK` states were added.
- The control outputs depend on both the current FSM state and the instruction opcode. This allows different instructions to generate different control signals while still following the same four-stage execution cycle.
- Since the CPU reuses the previously designed 4-bit ALU, opcodes `0000–1011` are reserved for ALU operations, allowing the opcode itself to be directly used as the `alu_op` signal.
