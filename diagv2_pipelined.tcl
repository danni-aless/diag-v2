cd [file normalize [file dirname [info script]]]

create_project diagv2_pipelined ./diagv2_pipelined -part xc7a35ticsg324-1L -force
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
create_fileset -simset isa
set_property -name {xsim.simulate.runtime} -value {500000ns} -objects [get_filesets isa]
create_fileset -simset benchmarks
set_property -name {xsim.simulate.runtime} -value {150000000ns} -objects [get_filesets benchmarks]
current_fileset -simset [ get_filesets benchmarks ]
delete_fileset [ get_filesets sim_1 ]
file delete ./diagv2_pipelined/diagv2_pipelined.srcs/sim_1

add_files -norecurse ./src_pipelined/diagv2_const.vh
foreach src [glob ./src_pipelined/*.v] {
    add_files -norecurse $src
}

move_files -fileset isa [get_files ./src_pipelined/diagv2_tb_isa.v]
add_files -fileset isa -norecurse ./src_pipelined/waveconfig_pipelined_isa.wcfg
foreach mem_file [glob ./riscv-tests/isa/*.mem] {
    add_files -fileset isa -norecurse $mem_file
}
move_files -fileset benchmarks [get_files ./src_pipelined/diagv2_tb_benchmarks.v]
add_files -fileset benchmarks -norecurse ./src_pipelined/waveconfig_pipelined_benchmarks.wcfg
foreach mem_file [glob ./riscv-tests/benchmarks/*.mem] {
    add_files -fileset benchmarks -norecurse $mem_file
}

set_property top diagv2_tb_isa [get_filesets isa]
set_property top_lib xil_defaultlib [get_filesets isa]
set_property top diagv2_tb_benchmarks [get_filesets benchmarks]
set_property top_lib xil_defaultlib [get_filesets benchmarks]

update_compile_order -fileset sources_1
update_compile_order -fileset isa
update_compile_order -fileset benchmarks