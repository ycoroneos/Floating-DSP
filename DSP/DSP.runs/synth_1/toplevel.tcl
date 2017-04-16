# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a200tsbg484-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/yanni/18.335/finalproj/DSP/DSP.cache/wt [current_project]
set_property parent.project_path /home/yanni/18.335/finalproj/DSP/DSP.xpr [current_project]
set_property XPM_LIBRARIES XPM_CDC [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part digilentinc.com:nexys_video:part0:1.1 [current_project]
set_property ip_output_repo /home/yanni/18.335/finalproj/DSP/DSP.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib {
  /home/yanni/18.335/finalproj/DSP/DSP.srcs/sources_1/new/i2cmaster.v
  /home/yanni/18.335/finalproj/DSP/DSP.srcs/sources_1/imports/new/adau1761_controller.v
  /home/yanni/18.335/finalproj/DSP/DSP.srcs/sources_1/imports/new/divider.v
  /home/yanni/18.335/finalproj/DSP/DSP.srcs/sources_1/imports/new/toplevel.v
}
read_ip -quiet /home/yanni/18.335/finalproj/DSP/DSP.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci
set_property used_in_implementation false [get_files -all /home/yanni/18.335/finalproj/DSP/DSP.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_board.xdc]
set_property used_in_implementation false [get_files -all /home/yanni/18.335/finalproj/DSP/DSP.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc]
set_property used_in_implementation false [get_files -all /home/yanni/18.335/finalproj/DSP/DSP.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_ooc.xdc]
set_property is_locked true [get_files /home/yanni/18.335/finalproj/DSP/DSP.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]

foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/yanni/18.335/finalproj/DSP/DSP.srcs/constrs_1/imports/verilog/NexysVideo_Master.xdc
set_property used_in_implementation false [get_files /home/yanni/18.335/finalproj/DSP/DSP.srcs/constrs_1/imports/verilog/NexysVideo_Master.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]

synth_design -top toplevel -part xc7a200tsbg484-1


write_checkpoint -force -noxdef toplevel.dcp

catch { report_utilization -file toplevel_utilization_synth.rpt -pb toplevel_utilization_synth.pb }
