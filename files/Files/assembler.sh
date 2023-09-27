#!/bin/bash

if [ ! -r $1 ]
then
	echo "Usage: $0 <dlx_assembly_file>.asm <output_directory/output_file>"
	exit 1
fi

output_path="$2"
asmfile=`echo $1 | sed s/[.].*//g`

output_dir=$(dirname "$output_path")
output_file=$(basename "$output_path")
mkdir -p "$output_dir"

perl ./assembler.bin/dlxasm.pl -o $asmfile.bin -list $asmfile.list $1
rm $asmfile.bin.hdr
cat $asmfile.bin | hexdump -v -e '/1 "%02X" /1 "%02X" /1 "%02X" /1 "%02X\n"' > "$output_dir/$output_file"
