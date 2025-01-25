//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_if.sv
//  Last modified+updates : 16/02/2023 (RM)
//                          25/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Interface for ACE Read Verification IP (UVC)
//  ======================================================================================================

//interface definition
interface aceread_if #(
  TP          = 0,
  AGENT_NAME  = "aceread_agent"
)(
  input clk,
  input rst_n
);

//importing uvm basics and other sv headers

import uvm_pkg::*;
import aceread_pkg::*;

//All AXI4 Read interface signals
//Read Address channel
logic [32 -1:0]               araddr  ;
logic [1:0]                   arid    ;
logic [8 -1:0]                arlen   ;
logic [2 : 0]                 arsize  ;
logic [1 : 0]                 arburst ;
logic                         arlock  ;
logic [3 : 0]                 arcache ;
logic [2 : 0]                 arprot  ;
logic [3 : 0]                 arqos   ;
logic [3 : 0]                 arregion;
logic [8 -1:0]                aruser  ; 
logic                         arvalid ;
logic                         arready ;
//ACE specific signals
logic [3:0]                   arsnoop ;
logic [1:0]                   ardomain;
logic [1:0]                   arbar   ;   
//Read Data channel
logic [128 -1:0]        rdata ;
logic [1:0]             rid   ;
logic                   rlast ;
logic [1:0]             rresp ;
logic [8 -1 :0]         ruser ;
logic                   rvalid;
logic                   rready;
logic                   rack  ;
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

endinterface : aceread_if