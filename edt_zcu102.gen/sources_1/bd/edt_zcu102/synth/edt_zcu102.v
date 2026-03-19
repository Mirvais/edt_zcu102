//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1.1 (win64) Build 6233196 Thu Sep 11 21:27:30 MDT 2025
//Date        : Thu Feb 26 00:44:35 2026
//Host        : MIRVAISMO running 64-bit major release  (build 9200)
//Command     : generate_target edt_zcu102.bd
//Design      : edt_zcu102
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "edt_zcu102,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=edt_zcu102,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_zynq_ultra_ps_e_cnt=1,synth_mode=None}" *) (* HW_HANDOFF = "edt_zcu102.hwdef" *) 
module edt_zcu102
   ();


  edt_zcu102_zynq_ultra_ps_e_0_0 zynq_ultra_ps_e_0
       (.pl_ps_irq0(1'b0));
endmodule
