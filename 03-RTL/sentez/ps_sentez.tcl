read_verilog rtl/islem_elemani.v
read_verilog rtl/sistolik_dizi.v
synth_design -top sistolik_dizi -part xc7a35tcpg236-1 -flatten_hierarchy rebuilt -mode out_of_context
write_verilog -mode funcsim -force sim/postsynth/dizi_ps.v
report_utilization -file sim/postsynth/dizi_kullanim.txt
