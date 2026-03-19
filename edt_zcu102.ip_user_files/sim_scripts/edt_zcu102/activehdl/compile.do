transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xilinx_vip
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/axi_vip_v1_1_21
vlib activehdl/zynq_ultra_ps_e_vip_v1_0_21
vlib activehdl/xil_defaultlib

vmap xilinx_vip activehdl/xilinx_vip
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_21 activehdl/axi_vip_v1_1_21
vmap zynq_ultra_ps_e_vip_v1_0_21 activehdl/zynq_ultra_ps_e_vip_v1_0_21
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xilinx_vip  -sv2k12 "+incdir+D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ipshared/ec67/hdl" "+incdir+../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ipshared/7711/hdl" "+incdir+../../../../../../Xilinx/2025.1.1/Vivado/data/rsb/busdef" "+incdir+D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib \
"../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_21  -sv2k12 "+incdir+../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ipshared/ec67/hdl" "+incdir+../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ipshared/7711/hdl" "+incdir+../../../../../../Xilinx/2025.1.1/Vivado/data/rsb/busdef" "+incdir+D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib \
"../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ipshared/f16f/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work zynq_ultra_ps_e_vip_v1_0_21  -sv2k12 "+incdir+../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ipshared/ec67/hdl" "+incdir+../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ipshared/7711/hdl" "+incdir+../../../../../../Xilinx/2025.1.1/Vivado/data/rsb/busdef" "+incdir+D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib \
"../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ipshared/7711/hdl/zynq_ultra_ps_e_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ipshared/ec67/hdl" "+incdir+../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ipshared/7711/hdl" "+incdir+../../../../../../Xilinx/2025.1.1/Vivado/data/rsb/busdef" "+incdir+D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 -l xil_defaultlib \
"../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/ip/edt_zcu102_zynq_ultra_ps_e_0_0/sim/edt_zcu102_zynq_ultra_ps_e_0_0_vip_wrapper.v" \
"../../../../edt_zcu102.gen/sources_1/bd/edt_zcu102/sim/edt_zcu102.v" \

vlog -work xil_defaultlib \
"glbl.v"

