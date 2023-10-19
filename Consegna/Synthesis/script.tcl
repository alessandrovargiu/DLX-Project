analyze -library WORK -format vhdl {../Modules/000-common.core/000-Constants.vhd ../Modules/000-common.core/003-INSTR_CODES.vhd ../Modules/a.b-Datapath.core/ALUComponents/Comparator.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.c-Logic.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.d-mux41_Generic.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.e-Shifter.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.f-Toplevelcomparator.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.a-P4_Adder/fa.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.a-P4_Adder/G.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.a-P4_Adder/iv.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.a-P4_Adder/nd2.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.a-P4_Adder/mux21_generic.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.a-P4_Adder/Pg.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.a-P4_Adder/PgNetwork.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.a-P4_Adder/sparsetree.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.a-P4_Adder/carryselect.vhd ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.a-P4_Adder/sum_generator.vhdl ../Modules/a.b-Datapath.core/ALUComponents/a.b.b.a-P4_Adder.vhd ../Modules/a.b-Datapath.core/a.b.a-RF.vhd ../Modules/a.b-Datapath.core/a.b.b-ProALU.vhd ../Modules/a.b-Datapath.core/A_register.vhd ../Modules/a.b-Datapath.core/B_register ../Modules/a.b-Datapath.core/comp4Branch.vhd ../Modules/a.b-Datapath.core/FA.vhd ../Modules/a.b-Datapath.core/FF.vhd ../Modules/a.b-Datapath.core/IR0_Register.vhd ../Modules/a.b-Datapath.core/mux2x1.vhd ../Modules/a.b-Datapath.core/mux4x1.vhd ../Modules/a.b-Datapath.core/oneBitMux2x1.vhd ../Modules/a.b-Datapath.core/RCA.vhd ../Modules/a.b-Datapath.core/register.vhd ../Modules/a.b-Datapath.core/sgn_extender.vhd ../Modules/a.a-CU.vhd ../Modules/a.b-Datapath.vhd ../Modules/a.c-HU.vhd ../Modules/a-CPU.vhd}
elaborate CPU -architecture DLX_arch -update -library WORK
set_wire_load_model -name 5K_hvratio_1_4
create_clock -name "CLK" -period 1.5 CLK
report_clock
#fix hold violations
set_fix_hold "CLK"
#for combinational circuits
set_max_delay 1.5 -from [all_inputs] -to [all_outputs]
compile -map_effort high
#reports
report_area > ./reports/CPU_area.txt
report_timing > ./reports/CPU_timing.txt
report_power > ./reports/CPU_power.txt
#netlists
write -hierarchy -format vhdl -output CPU_postsynth.vhdl
write -hierarchy -format verilog -output CPU_postsynth.v


