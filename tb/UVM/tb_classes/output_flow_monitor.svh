/***********************************************************************
  $FILENAME    : output_flow_monitor.svh

  $TITLE       : FIFO output data flow monitor

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This class monitors the output data flow out of FIFO and 
                 transmits its acquired data towards scoreboard module.

************************************************************************/


class output_flow_monitor extends uvm_component;
  `uvm_component_utils(output_flow_monitor);

  // Bus Functional Model interface
  virtual async_fifo_bfm bfm;
  // Broadcasts the monitored read data from FIFO value to corresponding 
  // subscribers (scoreboard).
  uvm_analysis_port #(output_flow_transaction) ap;


  //
  // Class constructor method
  //
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new


  //
  // Overrides UVM build_phase method
  // This method is called top-down by the UVM "root".
  // The build_phase is where the Testbench is constructed, 
  // connected and configured.
  //
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual async_fifo_bfm)::get(null, "*","bfm", bfm))
      `uvm_fatal("DRIVER", "output_flow_monitor::Failed to get BFM");
    ap  = new("ap", this);
  endfunction : build_phase


  //
  // Overrides UVM connect_phase method
  //
  function void connect_phase(uvm_phase phase);
    bfm.output_flow_monitor_h = this;
  endfunction : connect_phase


  //
  // Transmits FIFO's rdata to scoreboard
  //
  function void write_to_monitor(logic [FIFO_DATA_WIDTH-1:0] rdata);
    output_flow_transaction output_flow_t;
    output_flow_t = new("output_flow_t");
    output_flow_t.rdata = rdata;
    ap.write(output_flow_t);
  endfunction : write_to_monitor


endclass : output_flow_monitor

