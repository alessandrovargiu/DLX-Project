set fp [open "./sources.f" r]
set files_to_analyze [read $fp]

foreach line [split [string trim "$files_to_analyze" "\n"] "\n"] {
    analyze -library work -format vhdl "$line"
}

elaborate CFG_CPU -update -library WORK
set_wire_load_model -name 5K_hvratio_1_4
create_clock -name "CLK" -period 1.50 CLK
report_clock
set_fix_hold "CLK"
set_max_delay 1.50 -from [all_inputs] -to [all_outputs] 
compile -map_effort high

exec mkdir -p reports
report_timing > "./reports/CFG_CPU_clk_1.5ns_timing.rpt"
report_area   > "./reports/CFG_CPU_clk_1.5ns_area.rpt"
report_power  > "./reports/CFG_CPU_clk_1.5ns_power.rpt"

exec mkdir -p netlists
write -format verilog -hierarchy -output "./netlists/CFG_CPU_1.5ns_postsyn.v"
exec mkdir -p design_compiler_sdc
write_sdc "./design_compiler_sdc/CFG_CPU_1.5ns_postsyn.sdc"

exec rm -rf work
exit

