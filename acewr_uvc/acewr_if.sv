//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : acewr_if.sv
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Interface for ACEWR Verification IP (UVC)
//  ======================================================================================================

//interface definition
interface acewr_if #(
  TP          = 0,
  AGENT_NAME  = "acewr_agent"
)(
  input clk,
  input rst_n
);

//importing uvm basics and other sv headers

import uvm_pkg::*;
import acewr_pkg::*;

//All AXI4WR interface signals
//Write Address channel
logic [32 -1:0]               awaddr  ;
logic [1:0]                   awid    ;
logic [8 -1:0]                awlen   ;
logic [2 : 0]                 awsize  ;
logic [1 : 0]                 awburst ;
logic                         awlock  ;
logic [3 : 0]                 awcache ;
logic [2 : 0]                 awprot  ;
logic [3 : 0]                 awqos   ;
logic [3 : 0]                 awregion;
logic [8 -1:0]                awuser  ; 
logic                         awvalid ;
logic                         awready ;
//ACE specific signals
logic [2: 0]                  awsnoop;
logic [1: 0]                  awdomain;
logic [1: 0]                  awbar;
logic                         awunique;
//Write Data channel
logic [128 -1:0]        wdata ;
logic [128/8 -1:0]      wstrb ;
logic                   wlast ;
logic [8 -1 :0]         wuser ;
logic                   wvalid;
logic                   wready;
logic                   wack;
//Write response channel
logic                   bid   ;
logic [1 : 0]           bresp ;
logic [8 -1:0]          buser ;
logic                   bvalid;
logic                   bready;
//Snoop address channel (AC) signals (snoop control and address associated to the snoop transaction)
logic           acvalid;
logic           acready;
logic [32-1 :0] acaddr; // must match AXI4 WR/R address bus width
logic [3 : 0]   acsnoop;
logic [2 : 0]   acprot;
//Snoop response channel (CR) signals (response to a snoop transaction, an associated data
//transfer on CD channel is expected)
logic        crvalid;
logic        crready;
logic [4: 0] crresp;   
//Snoop data channel (CD) signals (passes snoop data out from a master)
logic            cdvalid;
logic            cdready;
logic [128-1 :0] cddata;
logic            cdlast; 

endinterface : acewr_if