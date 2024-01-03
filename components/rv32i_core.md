# Multicycle RISC-V CPU - Core Design

Our final project is designing a working rv32i (integer subset of the RISC-V
spec) system. The overall system consists of a computation core (datapath, alu,
register file, etc.) and a Memory Management Unit (MMU). The MMU will be
critical when we start connecting our CPU to external peripherals, but for now
we will be using `rv32_simulator.sv` as our top level module that

Your task is to implement `rv32i_multicycle_core.sv`. A computational core takes
in our typical `clk`, `rst`, and `ena` signals, and can interface with memory
via the ;`mem_access`, `mem_addr`, `mem_wr_data`, `mem_wr_ena`, and
`mem_rd_data` signals. By convention the core can only read xor write to memory
in a given cycle. You should also check `rv32i_common.sv` - it contains some
useful constants from the ISA.

You are allowed to use any mix of behavioral or structural HDL for this lab, but
remember that clearly drawing boundaries between your combinational logic
(`always_comb`) and your registers/FSMs (`always_ff`) makes debugging much
easier.

_Warning_ - the textbook's figures in Chapter 7 intentionally omit a lot of
hardware (or show smaller muxes/decoders than are actually required). Use the
readings as a guide, not an exact blueprint! I recommend sketching out the
datapath (flow of signals between PC, the register file, the ALU, and the
memory) for each type of instruction, updating it as you create more signals,
muxes, decoders, etc. You may find it helpful to refer to the more detailed
description of the instruction set in Chapter 6, though the reference card is
included in this folder. For full detail you can refer to the
[Official RISC-V Manual](https://riscv.org/wp-content/uploads/2019/12/riscv-spec-20191213.pdf)

## Assembler

To test a CPU you need a populated instruction memory. I've provided a simple
python assembler (`assembler.py`), please skim the file and its usage in
`Makefile` before proceeding. `assembler.py` generates `memh` files (ascii hex)
that can be loaded by our simulation and synthesis tools.

There is also a `disassembler.py` file, you may find that useful for debugging
but I mostly just included it for completeness (it's how I tested the
assembler.)

## Running Tests

The `Makefile` uses some extra arguments and dependencies to first run the
assembler to make a `memh` file, then run `iverilog` with a special flag to load
the right assembly into instruction memory. The various `make test_rv32i_*`
targets are a suggested flow toward implementing a complete core. After running
a test you can use `make waves_rv32i_system &` to visualize the results.

## Suggested Timeline

Designing your own CPU from scratch is both challenging and rewarding. I've
provided a some scaffolding here, but have intermediate solutions available on
request for each of the following milestones.

- By 12/1:
  - Instantiate a working register file and ALU (you can use
    `alu_behavioral.sv`).
  - Implement a FETCH state that stores `mem[PC]` into the `IR` instruction
    register and increments PC by four.
- By 12/6:
  - Implement a few I type instructions
  - Implement a few R type instructions
- By 12/8:
  - Implement loads and stores (full word only)
- By 12/10:
  - Branch and jump instructions.
    - Implement
- By 12/13:
  - Full system test with peripherals (described in separate document).

## Hints and Tips

- Getting annoyed with icarus verilog's apologetic verbose outputs? You can
  filter command line tools using `grep` like so.
  - `make test_rv32_itypes 2>&1 | grep -v 'sorry: constant selects'`
  - the `2>&1` redirects the stderr (where warnings are typically printed) to
    stdout for filtering.
  - `grep` searches for strings, the `-v` flag searches for any line that
    doesn't match the string. `grep` has a lot of search options (regular
    expressions, etc.) that can be very helpful for various command line tools.
  - You can combine a bunch of these together like so:
    `clear; make test_rv32_itypes 2>&1 | grep -v 'sorry: constant selects' | grep -v 'always_comb process has no sensitivities'`
- `print` or `$display` based debugging will only help so much for this
  project - using `gtkwave` to visualize the results will be much more helpful.
- The more concise the verilog, the harder it is to visualize which part of a
  long expression has a bug. Draw schematics, think in terms of hardware, and
  make sure you have a name for every meaningful bus in your design.
- A large difficulty of this lab is just tracking which instruction your core is
  trying to execute, as well as having human readable versions of the massive
  amount of bits in the waveform viewer. The following tools are aimed to help
  with that:
  - The custom `assembler.py` tool generates annotated `memh` files by default.
    If you open the corresponding `memh` file for assembly it will show you both
    the raw hex value and the original assembly line that it came from.
  - `gtkwave` can translate bits into words with the aid of
    `Translate Filter Files` and `Translate Filter Processes`.
    - `Translate Filter Files` are great for expressing `enum` types like states
      and mux select inputs. This
      [guide](http://moxielogic.org/blog/gtkwave-tip-2-translate-filter-files.html)
      shows how to set them up. Note that you will have to have the radix in the
      file match the radix in gtkwave (e.g. if you are writing unsigned decimal
      values in your filter file, you should right click and make sure that the
      representation of that signal in gtkwave is unsigned decimal as well.)
    - `Translate Filter Processes` are similar to the filter files, but use code
      to represent the output instead. `gtkwave_filter.py` is an example that
      runs a disassembler on an instruction and represents it in human readable
      assembly instead. If you add this to your `IR` register in gtkwave it will
      make it much much much easier to see what your core is doing. To use, make
      sure that the IR is displayed in hexadecimal, then right click,
      `Data Format` -> `Translate Filter Process` -> `Enable and Select`. Then
      browse for `gtkwave_filter.py` and make sure it is highlighted before
      selectiong `OK`.

# Final Deliverable

The PASS for this project is a core that works in simulation, to EXCEL I will
also requie some analysis about the performance of the ALU and core.

I will collect a submission that has every thing needed to run your simulation

## Instruction Checklist

Excel instructions are in italics.

### R-types

- [&check;] add
- [&check;] sub
- [&check;] xor
- [&check;] or
- [&check;] and
- [&check;] sll
- [&check;] srl
- [&check;] sra
- [&check;] slt
- [&check;] sltu

### I-types

- [&check;] addi
- [&check;] xori
- [&check;] ori
- [&check;] andi
- [&check;] slli
- [&check;] srli
- [&check;] srai
- [&check;] slti
- [&check;] sltiu

### Memory-Types (Loads/Stores)

- [&check;] lw
- [&check;] sw
- [ ] _lb_
- [ ] _lh_
- [ ] _lbu_
- [ ] _lhu_
- [ ] _sb_
- [ ] _sh_

### B-types (Branches)

- [&check;] beq
- [&check;] bne
- [&check;] _blt_
- [&check;] _bge_
- [&check;] _bltu_
- [&check;] _bgeu_

### J-types (Jumps)

- [&check;] jal
- [&check;] jalr (technically an i-type)

### U-types (Upper immediates)

- [ ] _lui_
- [ ] _auipc_

Note, the above list doesn't include some common psuedo-instructions like `ret`
and `j` and `not` since those can be expressed in terms of what we've already
listed here. See `assembler.py` for more details.
