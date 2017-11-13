/***********************************************************************
  $FILENAME    : async_fifo_base_test.svh

  $TITLE       : User-defined UVM base class tests fro async FIFO

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : async_fifo_base_test class inherits from uvm_test and
                 is used as a base class for other test class for the
                 FIFO verification.

************************************************************************/


class async_fifo_base_test extends uvm_test;

  env       env_h;
  sequencer sequencer_h;
   
  //
  // Class constructor method
  //
  function new (string name, uvm_component parent);
    super.new(name,parent);
  endfunction : new


  //
  // Overrides UVM build_phase method
  //
  function void build_phase(uvm_phase phase);
    env_h = env::type_id::create("env_h", this);
  endfunction : build_phase


  //
  // Overrides UVM end_of_elaboration_phase method
  //
  function void end_of_elaboration_phase(uvm_phase phase);
    sequencer_h = env_h.sequencer_h;
  endfunction : end_of_elaboration_phase


endclass

