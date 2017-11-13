/***********************************************************************
  $FILENAME    : runall_sequence.svh

  $TITLE       : Integrates several sequencer modules in one place

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : 

************************************************************************/


class runall_sequence extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(runall_sequence);

  protected random_sequence random;
  protected sequencer sequencer_h;
  protected uvm_component uvm_component_h;


  //
  // Class constructor method
  //
  function new(string name = "runall_sequence");
    super.new(name);
    
    uvm_component_h =  uvm_top.find("*.env_h.sequencer_h");

    if (uvm_component_h == null)
      `uvm_fatal("RUNALL SEQUENCE", "Failed to get the sequencer")

    if (!$cast(sequencer_h, uvm_component_h))
      `uvm_fatal("RUNALL SEQUENCE", "Failed to cast from uvm_component_h.")
      
    random = random_sequence::type_id::create("random");
  endfunction : new


  //
  // Overrides UVM body method
  //
  task body();
    random.start(sequencer_h);
  endtask : body
   
endclass : runall_sequence

