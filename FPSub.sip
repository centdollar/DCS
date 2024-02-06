set_global_assignment -entity "FPSub" -library "lib_FPSub" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "FPSub" -library "lib_FPSub" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "FPSub" -library "lib_FPSub" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_FPSub" -name SPD_FILE [file join $::quartus(sip_path) "FPSub.spd"]

set_global_assignment -library "lib_FPSub" -name MISC_FILE [file join $::quartus(sip_path) "FPSub_sim/FPSub.vo"]
