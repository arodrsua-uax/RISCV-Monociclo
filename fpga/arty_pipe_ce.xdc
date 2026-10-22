create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk100 }];

# El procesador solo avanza en los pulsos ce (uno cada DIV >= 2 ciclos):
# sus caminos pueden usar 2 ciclos de reloj.
set cpu_regs [get_cells -hier -filter {IS_SEQUENTIAL && NAME =~ cpu/*}]
set_multicycle_path 2 -setup -from $cpu_regs -to $cpu_regs
set_multicycle_path 1 -hold  -from $cpu_regs -to $cpu_regs