transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xilinx_vip
vlib riviera/xpm
vlib riviera/axi_datamover_v5_1_37
vlib riviera/axi_sg_v4_1_21
vlib riviera/axi_dma_v7_1_36
vlib riviera/xil_defaultlib

vmap xilinx_vip riviera/xilinx_vip
vmap xpm riviera/xpm
vmap axi_datamover_v5_1_37 riviera/axi_datamover_v5_1_37
vmap axi_sg_v4_1_21 riviera/axi_sg_v4_1_21
vmap axi_dma_v7_1_36 riviera/axi_dma_v7_1_36
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xilinx_vip  -incr -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 "+incdir+D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xil_defaultlib \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr -l axi_vip_v1_1_21 -l zynq_ultra_ps_e_vip_v1_0_21 "+incdir+../../../../../../Xilinx/2025.1.1/Vivado/data/rsb/busdef" "+incdir+D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xil_defaultlib \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work axi_datamover_v5_1_37 -93  -incr \
"../../../ipstatic/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vcom -work axi_sg_v4_1_21 -93  -incr \
"../../../ipstatic/hdl/axi_sg_v4_1_rfs.vhd" \

vcom -work axi_dma_v7_1_36 -93  -incr \
"../../../ipstatic/hdl/axi_dma_v7_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../edt_zcu102.gen/sources_1/ip/axi_dma_0/sim/axi_dma_0.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

