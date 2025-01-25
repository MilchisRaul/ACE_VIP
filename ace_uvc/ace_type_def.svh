//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_type_def.svh
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Type defines structures for ACE Verification IP (UVC)
//  ======================================================================================================

typedef enum {MASTER, SLAVE} agent_type_t;
typedef enum {VAL_BFR_RDY, RDY_BFR_VAL, VAL_AND_RDY} hsk_type; //defining the handshake type to declare new vars
//defining the delay type to declare new vars for all channels
typedef enum {B2B, SHORT, MEDIUM, LONG } delay_type;      //B2B=0 , SHORT=1, MEDIUM=2, LONG=3 
//defining cache line states
typedef enum {UNIQUE_CLEAN, UNIQUE_DIRTY, SHARED_CLEAN, SHARED_DIRTY, INVALID} cache_states;

