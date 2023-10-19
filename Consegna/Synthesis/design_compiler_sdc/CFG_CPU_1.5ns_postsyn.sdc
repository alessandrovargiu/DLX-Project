###################################################################

# Created by write_sdc on Wed Oct 18 21:01:55 2023

###################################################################
set sdc_version 2.1

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current mA
set_wire_load_model -name 5K_hvratio_1_4 -library NangateOpenCellLibrary
create_clock [get_ports CLK]  -period 1.5  -waveform {0 0.75}
set_max_delay 1.5  -from [list [get_ports CLK] [get_ports reset] [get_ports enable] [get_ports   \
{IramDATA[31]}] [get_ports {IramDATA[30]}] [get_ports {IramDATA[29]}]          \
[get_ports {IramDATA[28]}] [get_ports {IramDATA[27]}] [get_ports               \
{IramDATA[26]}] [get_ports {IramDATA[25]}] [get_ports {IramDATA[24]}]          \
[get_ports {IramDATA[23]}] [get_ports {IramDATA[22]}] [get_ports               \
{IramDATA[21]}] [get_ports {IramDATA[20]}] [get_ports {IramDATA[19]}]          \
[get_ports {IramDATA[18]}] [get_ports {IramDATA[17]}] [get_ports               \
{IramDATA[16]}] [get_ports {IramDATA[15]}] [get_ports {IramDATA[14]}]          \
[get_ports {IramDATA[13]}] [get_ports {IramDATA[12]}] [get_ports               \
{IramDATA[11]}] [get_ports {IramDATA[10]}] [get_ports {IramDATA[9]}]           \
[get_ports {IramDATA[8]}] [get_ports {IramDATA[7]}] [get_ports {IramDATA[6]}]  \
[get_ports {IramDATA[5]}] [get_ports {IramDATA[4]}] [get_ports {IramDATA[3]}]  \
[get_ports {IramDATA[2]}] [get_ports {IramDATA[1]}] [get_ports {IramDATA[0]}]  \
[get_ports {DramDATA_IN[31]}] [get_ports {DramDATA_IN[30]}] [get_ports         \
{DramDATA_IN[29]}] [get_ports {DramDATA_IN[28]}] [get_ports {DramDATA_IN[27]}] \
[get_ports {DramDATA_IN[26]}] [get_ports {DramDATA_IN[25]}] [get_ports         \
{DramDATA_IN[24]}] [get_ports {DramDATA_IN[23]}] [get_ports {DramDATA_IN[22]}] \
[get_ports {DramDATA_IN[21]}] [get_ports {DramDATA_IN[20]}] [get_ports         \
{DramDATA_IN[19]}] [get_ports {DramDATA_IN[18]}] [get_ports {DramDATA_IN[17]}] \
[get_ports {DramDATA_IN[16]}] [get_ports {DramDATA_IN[15]}] [get_ports         \
{DramDATA_IN[14]}] [get_ports {DramDATA_IN[13]}] [get_ports {DramDATA_IN[12]}] \
[get_ports {DramDATA_IN[11]}] [get_ports {DramDATA_IN[10]}] [get_ports         \
{DramDATA_IN[9]}] [get_ports {DramDATA_IN[8]}] [get_ports {DramDATA_IN[7]}]    \
[get_ports {DramDATA_IN[6]}] [get_ports {DramDATA_IN[5]}] [get_ports           \
{DramDATA_IN[4]}] [get_ports {DramDATA_IN[3]}] [get_ports {DramDATA_IN[2]}]    \
[get_ports {DramDATA_IN[1]}] [get_ports {DramDATA_IN[0]}]]  -to [list [get_ports {IramADDR[31]}] [get_ports {IramADDR[30]}] [get_ports    \
{IramADDR[29]}] [get_ports {IramADDR[28]}] [get_ports {IramADDR[27]}]          \
[get_ports {IramADDR[26]}] [get_ports {IramADDR[25]}] [get_ports               \
{IramADDR[24]}] [get_ports {IramADDR[23]}] [get_ports {IramADDR[22]}]          \
[get_ports {IramADDR[21]}] [get_ports {IramADDR[20]}] [get_ports               \
{IramADDR[19]}] [get_ports {IramADDR[18]}] [get_ports {IramADDR[17]}]          \
[get_ports {IramADDR[16]}] [get_ports {IramADDR[15]}] [get_ports               \
{IramADDR[14]}] [get_ports {IramADDR[13]}] [get_ports {IramADDR[12]}]          \
[get_ports {IramADDR[11]}] [get_ports {IramADDR[10]}] [get_ports               \
{IramADDR[9]}] [get_ports {IramADDR[8]}] [get_ports {IramADDR[7]}] [get_ports  \
{IramADDR[6]}] [get_ports {IramADDR[5]}] [get_ports {IramADDR[4]}] [get_ports  \
{IramADDR[3]}] [get_ports {IramADDR[2]}] [get_ports {IramADDR[1]}] [get_ports  \
{IramADDR[0]}] [get_ports {DramDATA_OUT[31]}] [get_ports {DramDATA_OUT[30]}]   \
[get_ports {DramDATA_OUT[29]}] [get_ports {DramDATA_OUT[28]}] [get_ports       \
{DramDATA_OUT[27]}] [get_ports {DramDATA_OUT[26]}] [get_ports                  \
{DramDATA_OUT[25]}] [get_ports {DramDATA_OUT[24]}] [get_ports                  \
{DramDATA_OUT[23]}] [get_ports {DramDATA_OUT[22]}] [get_ports                  \
{DramDATA_OUT[21]}] [get_ports {DramDATA_OUT[20]}] [get_ports                  \
{DramDATA_OUT[19]}] [get_ports {DramDATA_OUT[18]}] [get_ports                  \
{DramDATA_OUT[17]}] [get_ports {DramDATA_OUT[16]}] [get_ports                  \
{DramDATA_OUT[15]}] [get_ports {DramDATA_OUT[14]}] [get_ports                  \
{DramDATA_OUT[13]}] [get_ports {DramDATA_OUT[12]}] [get_ports                  \
{DramDATA_OUT[11]}] [get_ports {DramDATA_OUT[10]}] [get_ports                  \
{DramDATA_OUT[9]}] [get_ports {DramDATA_OUT[8]}] [get_ports {DramDATA_OUT[7]}] \
[get_ports {DramDATA_OUT[6]}] [get_ports {DramDATA_OUT[5]}] [get_ports         \
{DramDATA_OUT[4]}] [get_ports {DramDATA_OUT[3]}] [get_ports {DramDATA_OUT[2]}] \
[get_ports {DramDATA_OUT[1]}] [get_ports {DramDATA_OUT[0]}] [get_ports         \
{DramADDR[31]}] [get_ports {DramADDR[30]}] [get_ports {DramADDR[29]}]          \
[get_ports {DramADDR[28]}] [get_ports {DramADDR[27]}] [get_ports               \
{DramADDR[26]}] [get_ports {DramADDR[25]}] [get_ports {DramADDR[24]}]          \
[get_ports {DramADDR[23]}] [get_ports {DramADDR[22]}] [get_ports               \
{DramADDR[21]}] [get_ports {DramADDR[20]}] [get_ports {DramADDR[19]}]          \
[get_ports {DramADDR[18]}] [get_ports {DramADDR[17]}] [get_ports               \
{DramADDR[16]}] [get_ports {DramADDR[15]}] [get_ports {DramADDR[14]}]          \
[get_ports {DramADDR[13]}] [get_ports {DramADDR[12]}] [get_ports               \
{DramADDR[11]}] [get_ports {DramADDR[10]}] [get_ports {DramADDR[9]}]           \
[get_ports {DramADDR[8]}] [get_ports {DramADDR[7]}] [get_ports {DramADDR[6]}]  \
[get_ports {DramADDR[5]}] [get_ports {DramADDR[4]}] [get_ports {DramADDR[3]}]  \
[get_ports {DramADDR[2]}] [get_ports {DramADDR[1]}] [get_ports {DramADDR[0]}]  \
[get_ports {cw_mem_bits[1]}] [get_ports {cw_mem_bits[0]}]]
