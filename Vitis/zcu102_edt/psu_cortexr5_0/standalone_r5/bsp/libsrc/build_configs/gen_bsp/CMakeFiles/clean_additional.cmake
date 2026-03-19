# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "D:\\VLSI\\Vivado_Projects\\edt_zcu102\\Vitis\\zcu102_edt\\psu_cortexr5_0\\standalone_r5\\bsp\\include\\sleep.h"
  "D:\\VLSI\\Vivado_Projects\\edt_zcu102\\Vitis\\zcu102_edt\\psu_cortexr5_0\\standalone_r5\\bsp\\include\\xiltimer.h"
  "D:\\VLSI\\Vivado_Projects\\edt_zcu102\\Vitis\\zcu102_edt\\psu_cortexr5_0\\standalone_r5\\bsp\\include\\xtimer_config.h"
  "D:\\VLSI\\Vivado_Projects\\edt_zcu102\\Vitis\\zcu102_edt\\psu_cortexr5_0\\standalone_r5\\bsp\\lib\\libxiltimer.a"
  )
endif()
