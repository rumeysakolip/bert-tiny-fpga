read_verilog rtl/pe.v
read_verilog rtl/systolic_nxn.v
synth_design -top systolic_nxn -part xc7a35tcpg236-1 -flatten_hierarchy rebuilt -mode out_of_context
write_verilog -mode funcsim -force sim/postsynth/dizi_ps.v
report_utilization -file sim/postsynth/dizi_kullanim.txt
