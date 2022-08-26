# Mips_Processor_MultiCycle
Design and implementation of a MIPS processor with multi-cycle controller and datapath.


Different modules are used in this processor, like ALU, different multiplexers, different registers, adder, a shift to left module, a sign extension module , register file and a PC, all implemented in Modules.v

Different modules like adder, register, shift register, up counter, multiplexer and comparator were used in this project. Each of these modules is defined in the Modules.v file.

Both the controller and the datapath are seperately defined in the Controller.v and Datapath.v files.

The top level module of the final divider is inititated in Toplevel.v, also a test bench was implemented to check the function of the divider, which is shown in the testbench.v file.

The text file is the assembly instruction for a program to find the maximum number in a list of 20 numbers, and store both the number and its index in the memory.
