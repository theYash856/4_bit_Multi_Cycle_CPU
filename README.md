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
|1100| LOAD | Rd ← MEM[Addr] |
|1101| STORE | MEM[Addr] ← Rd |
|1110| JUMP | PC ← Jump_Addr|
|1111| HALT | CPU execution stops |


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
#### Purpose 
The Main Memory module serves two different purposes in the CPU:

  **1.** Stores the program instructions. <br>
  **2.** Stores data values used by LOAD and STORE instructions.
  
Since instructions and data share the same memory, the CPU follows a Von Neumann architecture.

#### Operations
- The memory contains both instructions and data.
- During the FETCH stage, the Program Counter provides the address.
- The memory outputs a 12-bit instruction which is loaded into the Instruction Register.
- During LOAD and STORE instructions, the address field of the instruction is used instead.
- STORE writes register data into memory.
- LOAD reads data from memory and sends it back to the register file.


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
The Control Unit coordinates the entire datapath by generating the control signals required during each stage of execution.

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

### F. CPU's ALU
#### Purpose
The ALU perfroms the combinational operations of the CPU. 

#### Operation
- The 4-bit ALU operations are self-explanatory as they follow the ISA provided in section 5.
- It also generates the Carry, Zero, Negative and Overflow flags.
- It is a hierarchical design, where `CPU_ALU` handles top-level control and and additional CPU operations, `ALU_4_bit` instantiates the `ALU_1_bit` cells.
- Shift, comparison, and increment operations are implemented directly inside the `CPU_ALU` module.

#### Design Decisions
- The hierarchical design was chosen to reuse the previous built [4-bit ALU](https://github.com/theYash856/4_bit_ALU).
- In order to maintain the originality of the exisitng project, a new top module `CPU_ALU` was used instead of the previous project's `ALU_TOP`.
- Opcode translation was performed to match the CPU instruction opcodes with the existing ALU opcodes.
- An `alu_enable` signal is used to ensure that the ALU remains active only during the EXECUTE and WRITEBACK stages of ALU instructions.

### G. CPU TOP

#### Purpose 
This is the module where the individual modules come together to make a functional processor. 

#### Operation
- Instantiates all six modules and connects them via internal wires.
- A memory address mux selects between `pc_out` during FETCH and `IR[3:0]` during LOAD/STORE, allowing shared memory access across different stages.
- A writeback mux selects between ALU result and memory data based on `mem_to_reg`, routing the correct data to the Register File.

## 8. Sample Program
As the CPU at this stage can't directly take inputs from the user, a preloaded sample program is is stored in the Main Memory to demonstrate the execution of different instructions.

| Address | Contents       | Meaning               |
| :------: | :--------------: |:---------------------: |
|  0 | LOAD R0,11     | Load first operand into R0   |
|  1 | LOAD R1,12     | Load second operand into R1  |
|  2 | SUB R0,R1      | Subtract R1 from R0 and store the result in R0   |
|  3 | INC R0         | Increment the result stored in R0     |
|  4 | STORE R0,14    | Store the value of R0 into memory location 14   |
|  5 | JUMP 7         | Skip next instruction |
|  6 | ADD R0,R1      | Should not execute    |
|  7 | HALT           | Stop CPU              |
|  11 | 0000_0000_0111 | Data value 7          |
|  12 | 0000_0000_0011 | Data value 3          |
|  14 | 0000_0000_0000 | Result location       |

## 9. Execution Flow
The execution of the sample program is shown below.

### Step 1: LOAD R0,11

The value stored at memory location 11 is loaded into register R0.

```text
R0 ← Memory[11]

R0 = 0111 (7)
R1 = 0
```
---

### Step 2: LOAD R1,12

The value stored at memory location 12 is loaded into register R1.

```text
R1 ← Memory[12]

R0 = 0111 (7)
R1 = 0011 (3)
```
---

### Step 3: SUB R0,R1

The ALU subtracts the contents of R1 from R0 and stores the result back into R0.

```text
R0 = 0111
R1 = 0011

R0 ← R0 - R1
R0 ← 0111 - 0011

R0 = 0100 (4)
```
---

### Step 4: INC R0

The value stored in R0 is incremented by one.

```text
R0 = 0100
R0 ← R0 + 0001

R0 = 0101 (5)
```
---

### Step 5: STORE R0,14

The result stored in R0 is written into memory location 14.

```text
Memory[14] ← R0

Memory[14] = 0101 (5)
```
---

### Step 6: JUMP 7

The Program Counter is updated to address 7, causing the next instruction to be skipped.

```text
PC = 5
PC = 7
```
---

### Step 7: HALT

The HALT instruction stops further execution of the processor.

```text
HALT = 1

CPU execution terminated.
```
---

### Final Result

```text
Memory[14] = 0000_0000_0101 (5)
```
