set_global_assignment -entity "FPDiv" -library "lib_FPDiv" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "FPDiv" -library "lib_FPDiv" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "FPDiv" -library "lib_FPDiv" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_FPDiv" -name SPD_FILE [file join $::quartus(sip_path) "FPDiv.spd"]

set_global_assignment -library "lib_FPDiv" -name MISC_FILE [file join $::quartus(sip_path) "FPDiv_sim/FPDiv_memoryC0_uid112_invTables_lutmem.hex"]
set_global_assignment -library "lib_FPDiv" -name MISC_FILE [file join $::quartus(sip_path) "FPDiv_sim/FPDiv_memoryC1_uid115_invTables_lutmem.hex"]
set_global_assignment -library "lib_FPDiv" -name MISC_FILE [file join $::quartus(sip_path) "FPDiv_sim/FPDiv.vo"]
