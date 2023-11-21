# DLX-Project
DLX architecture implementation for the MicroElectronic Systems course project at Polytechnic of Turin.

DLX is an architecture for RISC processors created by Hennessy and Patterson, based on MIPS.

The project consists in developing a VHDL implementation from scratch of the DLX architecture.

Main components of the architecture are:
    - Datapath
    - Control Unit
    - Hazard Unit

Control and Hazard Unit are implemented in a full behavioral way.
The datapath contains Structural implementations of arithmetic circuits, like the Pentium P4 Adder and the OpenSparc T2 Shifter.

Most relevant steps of a typical Design Flow were implemented.
    - Simulation (using Modelsim)
    - Logic Synthesis (using Synopsys Design Compiler tools)
    - Place&Route (using Cadence Innovus)









