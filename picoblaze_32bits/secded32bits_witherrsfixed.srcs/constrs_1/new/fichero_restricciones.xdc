set_property PACKAGE_PIN Y9 [get_ports clk]
set_property PACKAGE_PIN T22 [get_ports LED]
set_property PACKAGE_PIN P16 [get_ports reset]
set_property PACKAGE_PIN Y10 [get_ports rx]
set_property PACKAGE_PIN AA11 [get_ports tx]
set_property SLEW SLOW [get_ports LED]
set_property PACKAGE_PIN F22 [get_ports err_en]
set_property PACKAGE_PIN T18 [get_ports interrupt]
set_property PACKAGE_PIN U14 [get_ports {led_err[1]}]
set_property PACKAGE_PIN U19 [get_ports {led_err[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led_err[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_err[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports interrupt]
set_property IOSTANDARD LVCMOS33 [get_ports LED]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports err_en]

create_clock -period 10.000 -name clk -waveform {0.000 5.000}



