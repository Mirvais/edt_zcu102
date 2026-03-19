# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "D:\\VLSI\\Vivado_Projects\\edt_zcu102\\Vitis\\zcu102_edt\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\include\\sleep.h"
  "D:\\VLSI\\Vivado_Projects\\edt_zcu102\\Vitis\\zcu102_edt\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\include\\xiltimer.h"
  "D:\\VLSI\\Vivado_Projects\\edt_zcu102\\Vitis\\zcu102_edt\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\include\\xtimer_config.h"
  "D:\\VLSI\\Vivado_Projects\\edt_zcu102\\Vitis\\zcu102_edt\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\lib\\libxiltimer.a"
  )
endif()
