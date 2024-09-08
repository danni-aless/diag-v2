cd [file normalize [file dirname [info script]]]

create_project diagv2_singlecycle ./diagv2_singlecycle -part xc7a35ticsg324-1L -force
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
create_fileset -simset isa
set_property -name {xsim.simulate.runtime} -value {500000ns} -objects [get_filesets isa]
current_fileset -simset [ get_filesets isa ]
delete_fileset [ get_filesets sim_1 ]
file delete ./diagv2_singlecycle/diagv2_singlecycle.srcs/sim_1

add_files -norecurse ./src_singlecycle/diagv2_const.vh
foreach src [glob ./src_singlecycle/*.v] {
    add_files -norecurse $src
}

move_files -fileset isa [get_files ./src_singlecycle/diagv2_tb.v]
add_files -fileset isa -norecurse ./src_singlecycle/waveconfig_singlecycle.wcfg
foreach mem_file [glob ./riscv-tests/isa/*.mem] {
    add_files -fileset isa -norecurse $mem_file
}

set_property top diagv2_tb [get_filesets isa]
set_property top_lib xil_defaultlib [get_filesets isa]

update_compile_order -fileset sources_1
update_compile_order -fileset isa