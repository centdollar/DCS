create_clock -period 20.000 -name clock_in [get_ports clock_in]

derive_pll_clocks

derive_clock_uncertainty