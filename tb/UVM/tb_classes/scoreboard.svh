/***********************************************************************
  $FILENAME    : scoreboard.svh

  $TITLE       : Scoreboard class implementation

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : The scoreboard class provides all the necessary methods
                 to compare actual results from the DUT to expected results.

************************************************************************/


class scoreboard extends uvm_subscriber #(output_flow_transaction);
  `uvm_component_utils(scoreboard);

  // storage of transactions between driver and scoreboard processes
  uvm_tlm_analysis_fifo #(sequence_item) input_flow_f;

   
  //
  // Class constructor method
  //
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new


  //
  // Overrides UVM build_phase method
  //
  function void build_phase(uvm_phase phase);
    input_flow_f = new ("input_flow_f", this);
  endfunction : build_phase


  //
  // Generates an output_flow_transaction for the expected data
  //
  function output_flow_transaction expected_output_flow(sequence_item input_flow);
    output_flow_transaction expected;
      
    expected = new("expected");
    expected.rdata = input_flow.wdata;
    return expected;

   endfunction : expected_output_flow
   

  //
  // Overrides UVM write method
  // write method: 
  //    Receives wdata from input_flow_monitor (sequence_item cmd)
  //    Receives rdata from output_flow_monitor (output_flow_transaction t)
  // This method compares the output data flow from FIFO and 
  // the previously inserted data into FIFO.
  //
  virtual function void write(output_flow_transaction t);
    string data_str;
    // Receives wdata from command_monitor
    sequence_item input_flow;
    output_flow_transaction expected;

    if (!input_flow_f.try_get(input_flow))
      $fatal(1, "scoreboard::Missing input_flow in self checker");

    expected = expected_output_flow(input_flow);

//    $display("%dns : scoreboard::Checking rdata: expected wdata = %h, rdata = %h", $time, input_flow.wdata, t.rdata);
//    assert(t.rdata === input_flow.wdata) else $error("%dns : scoreboard::Checking failed: expected wdata = %h, rdata = %h", $time, input_flow.wdata, t.rdata);
      
    data_str = {                     input_flow.convert2string(), 
                  " ==>  Actual "  , t.convert2string(), 
                  "/expected "     , expected.convert2string()};

    if (!expected.compare(t))
      `uvm_error("SCOREBOARD SELF CHECKER", {"FAIL: ", data_str})
    else
      `uvm_info ("SCOREBOARD SELF CHECKER", {"PASS: ", data_str}, UVM_LOW)

  endfunction : write


endclass : scoreboard

