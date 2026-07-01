# 4-bit Multi-Cycle CPU – Technical Design Report

## 1. Motivation 
In order to understand the theory of combinational and sequential circuits practically, I previously built the [4-bit ALU](https://github.com/theYash856/4_bit_ALU) and [4-Floor Elevator Controller](https://github.com/theYash856/4_Floor_Elevator_Controller) projects.

Having completed the standard Digital System Design (DSD) concepts, I wanted to move beyond individual modules and understand how digital components work together to form a complete processor. This led to the development of 4-bit CPU as **the culminating project**.

The objective is not just to implement a CPU in Verilog, but to understand the fundamentals of Computer Organisation & Architecture (COA) — memory organisation, register types, control logic, and the fetch-decode-execute cycle — through practical implementation.

## 2. Design Methodology

The CPU was developed using **a bottom-up modular approach**, where individual components such as the Register File, Main Memory, Program Counter, Instruction Register, and Control Unit were first designed and verified independently. The previously developed `4-bit ALU` was reused and integrated into the processor. After validating the individual modules through simulation, they were integrated within the top-level `CPU_TOP` module to form the complete processor.

The processor follows the **Von Neumann architecture**, where instructions and data share a unified memory space. **A multi-cycle execution model** was adopted to divide instruction execution into separate `FETCH`, `DECODE`, `EXECUTE`, and `WRITEBACK` stages. This approach simplifies the control logic, allows each stage to be observed independently, and provides a better understanding of datapath and control path interactions.

## 3. Individual Module Design
Each module was independently designed, implemented, and verified through simulation before integration into the top-level CPU. The following sections describe the purpose, operation, and design decisions behind each module.

### 3.1 Program Counter (PC)
#### Purpose
It acts as the CPU's position tracker. It stores the address of the next instruction to be executed. 

#### Operation
- It resets to 0 if `rst` is 1.
- Increments by 1 on every clock cycle.
- Loads the `jump_address` during `jump` signal.
- Provides the current address to the memory.

### 3.2 Register File 
#### Purpose 
It acts as the CPU's internal memory. It stores the operands required by the ALU as well as the computed results.

#### Operation
- Contains 4 General Purpose Registers (R0-R3).
- The registers can act as both source and destination registers depending on the instruction being executed.
- The `write_enable` signal writes the data only when it is 1, otherwise the previous value is retained.
- If `rst` is 1, all the registers are cleared to `0000`.
- Supports two simultaneous combinational reads (operand A and operand B) to feed the ALU in the same cycle.

### 3.3 Main Memory
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

### 3.4 Instruction Register (IR)
#### Purpose

IR stores the fetched instruction temporarily so that it can be decoded and executed during subsequent clock cycles. Without the IR, the instruction would be lost once the Program Counter advances to the next address.

#### Operation

- The instruction from memory is loaded into the IR during the `FETCH` stage.
- The stored instruction is then used by the Control Unit and datapath during `DECODE` and `EXECUTE` stages.
- The instruction remains unchanged until a new instruction is fetched or the register is reset.

### 3.5 Control Unit (CU)

> The Control Unit plays a central role in the operation of the processor and is therefore discussed separately in the Section 4.

### 3.6 CPU's ALU
#### Purpose
The ALU performs the combinational operations of the CPU. 

#### Operation
- The 4-bit ALU operations are self-explanatory as they follow the ISA provided in section 5.
- It also generates the Carry, Zero, Negative and Overflow flags.
- It is a hierarchical design, where `CPU_ALU` handles top-level control and additional CPU operations, `ALU_4_bit` instantiates the `ALU_1_bit` cells.
- Shift, comparison, and increment operations are implemented directly inside the `CPU_ALU` module.

#### Design Decisions
- The hierarchical design was chosen to reuse the previously built [4-bit ALU](https://github.com/theYash856/4_bit_ALU).
- In order to maintain the originality of the existing project, a new top module `CPU_ALU` was used instead of the previous project's `ALU_TOP`.
- Opcode translation was performed to match the CPU instruction opcodes with the existing ALU opcodes.
- An `alu_enable` signal is used to ensure that the ALU remains active only during the EXECUTE and WRITEBACK stages of ALU instructions.

### 3.7 CPU TOP

#### Purpose 
This is the module where the individual modules come together to make a functional processor. 

#### Operation
- Instantiates all six modules and connects them via internal wires.
- A memory address mux selects between `pc_out` during FETCH and `IR[3:0]` during LOAD/STORE, allowing shared memory access across different stages.
- A writeback mux selects between ALU result and memory data based on `mem_to_reg`, routing the correct data to the Register File.

## 4. Control Unit (CU) Design
### 4.1 Purpose
The Control Unit acts as the brain of the CPU by generating the control signals required to coordinate instruction execution. The CPU follows a multi-cycle execution model:

`FETCH` → `DECODE` → `EXECUTE` → `WRITEBACK` → `FETCH`

### 4.2 Operation

**4.2.1. FETCH State**
- Fetches the next instruction from memory and loads it into the Instruction Register.
- Activates the `ir_load` signal.

**4.2.2. DECODE State**
- Decodes the instruction opcode and instruction fields.
- Determines the type of instruction being executed.
- No control signals are asserted during this stage, as instruction decoding is performed internally.

**4.2.3. EXECUTE State**

The instruction performed depends on the `opcode`:

- ALU instructions enable the ALU and pass the `opcode` as `alu_op`.
- LOAD instructions activate the `mem_read` signal to read from memory.
- JUMP instructions activate the `jump_enable` signal.

**4.2.4. WRITEBACK State**

Similar to the `EXECUTE` state, the `opcode` determines the operation:

- ALU instructions write the ALU result back to the register file using `reg_write`, while `alu_enable` remains asserted during the writeback cycle.
- LOAD instructions write memory data into the destination register using `reg_write` and `mem_to_reg`, while `mem_read` remains asserted until the data transfer is complete.
- STORE instructions write to memory here via `mem_write`.
- The Program Counter is updated to fetch the next instruction after the cycle completes.
- HALT instructions assert `halt` and prevent further PC updates, the FSM remains locked in `WRITEBACK` until `rst` is applied.

### 4.3 Design Decisions
- The initial design executed the complete fetch–decode–execute sequence within a single clock cycle, which eliminated the need for a FSM. The design was later extended to a multi-cycle architecture by introducing separate `FETCH`, `DECODE`, `EXECUTE`, and `WRITEBACK` states.
- The control outputs depend on both the current FSM state and the instruction opcode. This allows different instructions to generate different control signals while still following the same four-stage execution cycle.
- Signals such as `alu_enable`, `mem_read`, and `mem_write` are held active through WRITEBACK rather than only EXECUTE, since downstream modules (Register File, Memory) require valid data during the writeback cycle.
- Since the CPU reuses the previously designed 4-bit ALU, opcodes `0000–1011` are reserved for ALU operations, allowing the opcode itself to be directly used as the `alu_op` signal.

## 5. Debugging Experience

Some design issues were encountered during module integration and system-level testing. Resolving these issues improved the overall functionality and reliability of the CPU.
 - Discovered that the LOAD instruction was initially *treating the memory address as data* rather than using it to fetch the value stored at that location. This issue was resolved by introducing a memory address multiplexer to select between the Program Counter and the instruction address field.

- Identified *a control logic issue* where the HALT instruction was not stopping the processor correctly. The problem was traced to the WRITEBACK stage logic and was resolved by properly asserting the halt signal during the final state.

## 6. Limitations & Future Improvements
### 6.1. Limitations 
- The current 4-bit datapath limits all register values, ALU results, and data values to the range 0–15.
- Unified memory limits data storage to the lower 4 bits of the 12-bit memory word.
- Status flags are generated but are not yet utilized for branching or decision-making.
- The design has only been verified through waveform simulation.

### 6.2. Future Improvements
- Extend the datapath width to 8 bits.
- Implement multiplication and division operations so that the ALU supports all basic arithmetic operations.
- Separate the Instruction Memory and Data Memory by adopting Harvard Architecture.
- Add flag-based conditional branching instructions.
- Implement the processor on FPGA hardware.

## 7. Tools & Concepts Used
- **Language:** Verilog HDL
- **EDA Tools:** Xilinx Vivado (Simulation and RTL analysis). The design is also compatible with online EDA platforms.
- **Concepts Used:** Basic Computer Organisation & Architecture (COA), multi-cycle FSM design, datapath and control path, and hierarchical design.

> [!NOTE]
> This document focuses on the architectural and implementation details of the processor. For the project overview, ISA summary, sample program, execution flow, simulation results, and simulation guide, refer to the [README](README.md).
