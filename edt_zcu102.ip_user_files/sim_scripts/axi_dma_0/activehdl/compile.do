transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xilinx_vip
vlib activehdl/xpm
vlib activehdl/axi_datamover_v5_1_37
vlib activehdl/axi_sg_v4_1_21
vlib activehdl/axi_dma_v7_1_36
vlib activehdl/xil_defaultlib

vmap xilinx_vip activehdl/xilinx_vip
vmap xpm activehdl/xpm
vmap axi_datamover_v5_1_37 activehdl/axi_datamover_v5_1_37
vmap axi_sg_v4_1_21 activehdl/axi_sg_v4_1_21
vmap axi_dma_v7_1_36 activehdl/axi_dma_v7_1_36
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xilinx_vip  -sv2k12 "+incdir+D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xil_defaultlib \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv2k12 "+incdir+../../../../../../Xilinx/2025.1.1/Vivado/data/rsb/busdef" "+incdir+D:/VLSI/Xilinx/2025.1.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axi_datamover_v5_1_37 -l axi_sg_v4_1_21 -l axi_dma_v7_1_36 -l xil_defaultlib \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"D:/VLSI/Xilinx/2025.1.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work axi_datamover_v5_1_37 -93  \
"../../../ipstatic/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vcom -work axi_sg_v4_1_21 -93  \
"../../../ipstatic/hdl/axi_sg_v4_1_rfs.vhd" \

vcom -work axi_dma_v7_1_36 -93  \
"../../../ipstatic/hdl/axi_dma_v7_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../../edt_zcu102.gen/sources_1/ip/axi_dma_0/sim/axi_dma_0.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

