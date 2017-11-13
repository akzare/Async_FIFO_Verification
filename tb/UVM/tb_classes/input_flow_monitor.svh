/***********************************************************************
  $FILENAME    : input_flow_monitor.svh

  $TITLE       : FIFO input data flow monitor

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This class monitors the input data flow into FIFO and 
                 transmits its acquired data towards scoreboard and 
                 coverage modules.

************************************************************************/


class input_flow_monitor extends uvm_component;
  `uvm_component_utils(input_flow_monitor);

  // Bus Functional Model interface
  virtual async_fifo_bfm bfm;
  // Broadcasts the monitored write data to FIFO value to corresponding 
  // subscribers (scoreboard and coverage).
  uvm_analysis_port #(sequence_item) ap;


  //
  // Class constructor method
  //
  function new (string name, uvm_component parent);
    super.new(name,parent);
  endfunction


  //
  // Overrides UVM build_phase method
  // This method is called top-down by the UVM "root".
  // The build_phase is where the Testbench is constructed, 
  // connected and configured.
  //
  function void build_phase(uvm_phase phase);

    if(!uvm_config_db #(virtual async_fifo_bfm)::get(null, "*", "bfm", bfm))
      `uvm_fatal("DRIVER", "input_flow_monitor::Failed to get BFM")

    ap  = new("ap",this);
  endfunction : build_phase


  //
  // Overrides UVM connect_phase method
  // The connect phase is used to make TLM connections between 
  // components or to assign handles to testbench resources.
  //
  function void connect_phase(uvm_phase phase);
    bfm.input_flow_monitor_h = this;
  endfunction : connect_phase


  //
  // Transmits FIFO's wdata to coverage and scoreboard
  //
  function void write_to_monitor(logic [FIFO_DATA_WIDTH-1:0] wdata);
    // push sequence into FIFO
    sequence_item push;
    `uvm_info ("INPUT FLOW MONITOR", $sformatf("input_flow_monitor::MONITOR: wdata: %2h",
                wdata), UVM_HIGH);
    push = new("push");
    push.wdata = wdata;
    ap.write(push);
  endfunction : write_to_monitor


endclass : input_flow_monitor

