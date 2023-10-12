analyze -library WORK -format vhdl {constants.vhd INSTR_CODES.vhd CU_dlx.vhd}
elaborate top_entity -architecture behavioral -library WORK
compile -exact_map
write -hierarchy -format vhdl -output CU_dlx_postsynth.vhdl

