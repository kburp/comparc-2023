SHELL=/bin/bash
IVERILOG=iverilog -g2012 -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array -y./ -y./tests -Y.sv -I./ -DSIMULATION
VVP=vvp
VVP_POST=-fst
# Comment out after --rcvar on lower res screens.
# TODO(avinash) - maybe do this based on an environment variable?
WAVES=gtkwave --rcvar 'fontname_signals Monospace 20' --rcvar 'fontname_waves Monospace 20'

# TODO(avinash) - use $@ more to clean up rules.

# Some Makefile magic. Look it up if you are curious about build systems!
.PHONY: clean

clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml *.out
	rm -rf .Xil

#########################################################################
## Misc. Combinational Components
#########################################################################

# Multiplexors
test_muxes : tests/test_muxes.sv mux*.sv
	${IVERILOG} $^ -o $@.bin && ${VVP} $@.bin ${VVP_POST}
waves_muxes : test_muxes tests/muxes.gtkw
	${WAVES} -a tests/muxes.gtkw muxes.fst

# Decoders
test_decoders : tests/test_decoders.sv decoder*.sv
	${IVERILOG} $^ -o $@.bin && ${VVP} $@.bin ${VVP_POST}
waves_decoders : test_decoders
	${WAVES} -a tests/decoders.gtkw decoders.fst

# Adders
test_adder_1 : tests/test_adder_1.sv adder_1.sv
	${IVERILOG} $^ -o $@.bin && ${VVP} $@.bin ${VVP_POST}
waves_adder_1 : test_adder_1
	${WAVES} -a tests/adder_1.gtkw adder_1.fst
test_adder_n : tests/test_adder_n.sv adder_1.sv adder_n.sv
	${IVERILOG} $^ -o $@.bin && ${VVP} $@.bin ${VVP_POST}
waves_adder_n : test_adder_n
	${WAVES} -a tests/adder_n.gtkw adder_n.fst

# Shifters
test_shifters : tests/test_shifters.sv sll.sv sra.sv
	${IVERILOG} $^ -o $@.bin && ${VVP} $@.bin ${VVP_POST}

# Comparators
test_comparators: tests/test_comparators.sv comparator_eq.sv comparator_lt.sv ${ADDER_SOURCES}
	${IVERILOG} $^ -o $@.bin && ${VVP} $@.bin ${VVP_POST}
waves_comparator: test_comparators
	${WAVES} comparators.fst


# ALU
test_alu:
# TODO(student) add any additional files you need here!
ALU_SRCS:=adder_1.sv adder_n.sv comparator_eq.sv comparator_lt.sv mux*.sv
ALU_TEST_FILES:=tests/test_alu.sv tests/alu_behavioural.sv
test_alu: ${ALU_TEST_FILES} ${ALU_SRCS} tests/alu_testcases.memh
	${IVERILOG} ${ALU_TEST_FILES} ${ALU_SRCS} -o test_alu.bin && ${VVP} test_alu.bin ${VVP_POST}

waves_alu: test_alu
		gtkwave alu.fst &

#########################################################################
## Misc. Sequential Components and Simple FSMs
#########################################################################
# Note to students - you will probably need to add extra source files to the following modules! 

# Edge Detector
test_edge_detector : tests/test_edge_detector.sv edge_detector.sv
	${IVERILOG} $^ -o $@.bin && ${VVP} $@.bin ${VVP_POST}
waves_edge_detector : test_edge_detector tests/edge_detector.gtkw
	${WAVES} -a tests/edge_detector.gtkw edge_detector.fst

# Pulse Generator
test_pulse_generator: tests/test_pulse_generator.sv pulse_generator.sv
	${IVERILOG} $^ -o $@.bin && ${VVP} $@.bin ${VVP_POST}
# TODO(student) - add your waves target here! It should include a --save or -a argument so that you can recall how you set up and labeled your waveforms.
# <<<SOLUTION
waves_pulse_generator: test_pulse_generator tests/pulse_generator.gtkw
	${WAVES} pulse_generator.fst -a tests/pulse_generator.gtkw
# SOLUTION>>>

# Triangle Generator
test_triangle_generator: tests/test_triangle_generator.sv triangle_generator.sv adder_n.sv register.sv comparator_eq.sv
	${IVERILOG} $^ -o $@.bin && ${VVP} $@.bin ${VVP_POST}
# TODO(student) - add your waves target here! It should include a --save or -a argument so that you can recall how you set up and labeled your waveforms.

# Pulse Width Modulator (PWM)
test_pwm: tests/test_pwm.sv pulse_generator.sv pwm.sv adder_n.sv register.sv comparator_lt.sv
	@echo "This might take a while, we're testing a lot of clock cycles..."
	${IVERILOG} $^ -o $@.bin && ${VVP} $@.bin ${VVP_POST}
# TODO(student) - add your waves target here! It should include a --save or -a argument so that you can recall how you set up and labeled your waveforms.

#########################################################################
## UART Driver
#########################################################################
UART_SRCS=uart_driver.sv
UART_TEST_SRCS=tests/test_uart_driver.sv

test_uart_driver: ${UART_TEST_SRCS} ${UART_SRCS}
	${IVERILOG} $^ -o test_uart_driver.bin && ${VVP} test_uart_driver.bin ${VVP_POST}

waves_uart_driver: test_uart_driver tests/uart_states.txt
	${WAVES} uart_driver.fst -a tests/uart_driver.gtkw


#########################################################################
## RV32 Core
#########################################################################

## Register File
# Note: you may need to modify this if you made your own register file.
DECODER_SRCS=decoder_1_to_2.sv  decoder_2_to_4.sv  decoder_3_to_8.sv  decoder_4_to_16.sv  decoder_5_to_32.sv
RFILE_SRCS=register_file.sv register.sv  $(DECODER_SRCS) $(MUX_SRCS)
test_register_file: tests/test_register_file.sv ${RFILE_SRCS}
	${IVERILOG} $^ -o $@.bin && ${VVP} $@.bin ${VVP_POST}
waves_register_file: test_register_file
	${WAVES} register_file.fst -a tests/register_file.gtkw

# Make sure that your alu sources are up to date! Use the behavioral if yours isn't done.
ALU_SRCS=alu.sv alu_types.sv

RV32I_SRCS=rv32i_multicycle_core.sv rv32_common.sv ${RFILE_SRCS} ${ALU_SRCS} 
# Assembles .s (human readable) files into .memh (verilog readable binary) files.
%.memh : %.s ../tools/assembler.py ../tools/rv32i.py
	../tools/assembler.py $< -o $@
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Instruction Type Tests
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
rv32_simulator: ${RV32I_SRCS} tests/rv32_simulator.sv
	${IVERILOG} -y ./rv32 $^ -s $@ -o $@

test_rv32_itypes: rv32_simulator ../asm/itypes.memh
	./rv32_simulator +initial_memory=../asm/itypes.memh ${VVP_POST}

test_rv32_ir_simple: rv32_simulator ../asm/ir_simple.memh
	./rv32_simulator +max_cycles=20 +initial_memory=../asm/ir_simple.memh ${VVP_POST}

test_rv32_irl_simple: rv32_simulator ../asm/irl_simple.memh
	./rv32_simulator +max_cycles=50 +initial_memory=../asm/irl_simple.memh ${VVP_POST}

test_rv32_irtypes: rv32_simulator ../asm/irtypes.memh
	./rv32_simulator +initial_memory=../asm/irtypes.memh ${VVP_POST}

test_rv32_branches: rv32_simulator ../asm/branch_simple.memh
	./rv32_simulator +max_cycles=100 +initial_memory=../asm/branch_simple.memh ${VVP_POST}

test_rv32_jumps: rv32_simulator ../asm/jump_simple.memh
	./rv32_simulator +max_cycles=1000 +initial_memory=../asm/jump_simple.memh ${VVP_POST}

waves_rv32: rv32_simulator
	${WAVES} -a tests/rv32.gtkw  rv32_simulator.fst
