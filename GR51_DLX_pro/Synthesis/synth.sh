#!/usr/bin/env bash
mkdir -p work
#exec setsynopsys

source /software/scripts/init_synopsys_64.11
source /software/scripts/init_synopsys_68.11
source /software/scripts/init_synopsys

if [ -z "$1" ] || [ -z "$2" ] ; then
	usage
	echo "error: missing parameters: design_name and/or clk_period_ns"
        exit 1
fi
    #dc_shell-xg-t -no_log -f synthesis.do -x "set design_name $1; set clk_period_ns $2" | tee design_compiler.log
    dc_shell -no_log -f synthesis.do  


