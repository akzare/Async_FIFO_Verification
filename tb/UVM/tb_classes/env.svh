/***********************************************************************
  $FILENAME    : env.svh

  $TITLE       : Comprises a complete UVM environment

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This UVM environment consist of the entire testbench.

************************************************************************/


class env extends uvm_env;
  `uvm_component_utils(env);

  sequencer           sequencer_h;
  coverage            coverage_h;
  scoreboard          scoreboard_h;
  driver              driver_h;
  input_flow_monitor  input_flow_monitor_h;
  output_flow_monitor output_flow_monitor_h;


  //
  // Class constructor method
  //
  function new (string name, uvm_component parent);
    super.new(name,parent);
  endfunction : new


  //
  // Overrides UVM build_phase method
  // The testbench component hierarchy is constructed by this method.
  //
  function void build_phase(uvm_phase phase);
    // stimulus objects
    sequencer_h  = new("sequencer_h", this);
    driver_h     = driver::type_id::create("driver_h", this);
    // monitors objects
    input_flow_monitor_h = input_flow_monitor::type_id::create("input_flow_monitor_h", this);
    output_flow_monitor_h  = output_flow_monitor::type_id::create("output_flow_monitor", this);
    // analysis objects
    coverage_h   = coverage::type_id::create ("coverage_h", this);
    scoreboard_h = scoreboard::type_id::create("scoreboard", this);
  endfunction : build_phase


  //
  // Overrides UVM connect_phase method
  //
  function void connect_phase(uvm_phase phase);
    // Inter-class communication: Source: Driver -> Destination: Sequencer
    driver_h.seq_item_port.connect(sequencer_h.seq_item_export);

    // Inter-class communication: Source: input_flow Monitor -> Destination: Coverage
    input_flow_monitor_h.ap.connect(coverage_h.analysis_export);
    // Inter-class communication: Source: input_flow Monitor -> Destination: Scoreboard
    input_flow_monitor_h.ap.connect(scoreboard_h.input_flow_f.analysis_export);
    // Inter-class communication: Source: input_flow Monitor -> Destination: Scoreboard
    output_flow_monitor_h.ap.connect(scoreboard_h.analysis_export);
  endfunction : connect_phase


endclass : env

