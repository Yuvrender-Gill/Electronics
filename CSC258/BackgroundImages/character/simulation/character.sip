set_global_assignment -entity "character" -library "lib_character" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "character" -library "lib_character" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "character" -library "lib_character" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_character" -name SPD_FILE [file join $::quartus(sip_path) "../character.spd"]
set_global_assignment -library "lib_character" -name MISC_FILE [file join $::quartus(sip_path) "../../character.qsys"]

set_global_assignment -library "lib_character" -name MISC_FILE [file join $::quartus(sip_path) "character.v"]
set_global_assignment -library "lib_character" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_character_lcd_communication.v"]
set_global_assignment -library "lib_character" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_character_lcd_initialization.v"]
set_global_assignment -library "lib_character" -name MISC_FILE [file join $::quartus(sip_path) "submodules/character_character_lcd_0.v"]
