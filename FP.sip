set_global_assignment -entity "FP" -library "lib_FP" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "FP" -library "lib_FP" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "FP" -library "lib_FP" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_FP" -name SPD_FILE [file join $::quartus(sip_path) "FP.spd"]

set_global_assignment -library "lib_FP" -name MISC_FILE [file join $::quartus(sip_path) "FP_sim/FP.vo"]
