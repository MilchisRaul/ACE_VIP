//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023 
//  File name             : ace_config.svh
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Config file for ACE Verification IP (UVC)
//  ======================================================================================================

class ace_config extends uvm_object;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  agent_type_t agent_type = MASTER;

  virtual ace_if v_if;

  `uvm_object_utils_begin(ace_config)
    `uvm_field_enum(uvm_active_passive_enum, is_active,    UVM_DEFAULT)
    `uvm_field_enum(agent_type_t,           agent_type,   UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "ace_config");
    super.new(name);
    //Create the virtual interface
  endfunction : new

endclass : ace_config