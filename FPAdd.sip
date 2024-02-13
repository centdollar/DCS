set_global_assignment -entity "FPAdd" -library "lib_FPAdd" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "FPAdd" -library "lib_FPAdd" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "FPAdd" -library "lib_FPAdd" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_FPAdd" -name SPD_FILE [file join $::quartus(sip_path) "FPAdd.spd"]

set_global_assignment -library "lib_FPAdd" -name MISC_FILE [file join $::quartus(sip_path) "FPAdd_sim/FPAdd.vo"]
