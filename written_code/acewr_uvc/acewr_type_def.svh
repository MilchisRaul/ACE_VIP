//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : axi4wr_type_def.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Type defines structures for ACEWR Verification IP (UVC)
//  ======================================================================================================

typedef enum {MASTER, SLAVE} agent_type_t;
typedef enum {VAL_BFR_RDY, RDY_BFR_VAL, VAL_AND_RDY} hsk_type; //defining the handshake type to declare new vars
//defining the delay type to declare new vars for all channels
typedef enum {B2B, SHORT, MEDIUM, LONG } delay_type;      //B2B=0 , SHORT=1, MEDIUM=2, LONG=3 
//defining transaction item for data
