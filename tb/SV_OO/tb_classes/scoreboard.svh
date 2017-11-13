/***********************************************************************
  $FILENAME    : scoreboard.svh

  $TITLE       : Scoreboard class implementation

  $DATE        : 11 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : The scoreboard class provides all the necessary methods
                 to compare actual results from the DUT to expected results.

************************************************************************/


class scoreboard;

  // Bus Functional Model interface
  virtual async_fifo_bfm bfm;

  // Model a queue for checking data
  logic [FIFO_DATA_WIDTH-1:0] verif_data_q[$];
  logic [FIFO_DATA_WIDTH-1:0] verif_wdata;


  //
  // Class constructor method
  //
  function new (virtual async_fifo_bfm b);
    bfm = b;
  endfunction : new


  //
  // This method detects the timestamp when FIFO gets into full state.
  //
  task monitor_full_state();
  begin
    forever begin : self_monitor
      @(posedge bfm.wfull) 
      $display("%dns : scoreboard::FIFO gets full!", $time);
    end : self_monitor
  end
  endtask : monitor_full_state


  //
  // This method detects the timestamp when FIFO gets out of empty state.
  //
  task monitor_empty_state();
  begin
    forever begin : self_monitor
      @(negedge bfm.rempty) 
      $display("%dns : scoreboard::FIFO gets out of empty state!", $time);
    end : self_monitor
  end
  endtask : monitor_empty_state


  //
  // This method monitors the input data flow into FIFO and adds them 
  // into class's internal queue.
  //
  task monitor_input_flow();
  begin
    bit [FIFO_DATA_WIDTH-1:0] data = 0;
    forever begin : self_monitor
      @ (posedge bfm.wclk iff bfm.winc);
      verif_data_q.push_front(bfm.wdata);
      $display("%dns : scoreboard::Monitoring wdata = %h", $time, bfm.wdata);
    end : self_monitor
  end
  endtask : monitor_input_flow


  //
  // This method compares the output data flow from FIFO and compares them 
  // against the previously inserted data into class's internal queue.
  //
  task flow_checker();
  begin
    forever begin : self_checker
      @ (negedge bfm.rclk iff bfm.rinc);
      verif_wdata = verif_data_q.pop_back();
      // Check the rdata against modeled wdata
      $display("%dns : scoreboard::Checking rdata: expected wdata = %h, rdata = %h", $time, verif_wdata, bfm.rdata);
      assert(bfm.rdata === verif_wdata) else $error("%dns : scoreboard::Checking failed: expected wdata = %h, rdata = %h", $time, verif_wdata, bfm.rdata);
    end : self_checker
  end
  endtask : flow_checker


  //
  // This method forks all the other class's methods to be executed foreover.
  //
  task execute();
    $write("%dns : scoreboard::Starting monitor and check\n", $time);
    fork
      monitor_full_state();
      monitor_empty_state();
      monitor_input_flow();
      flow_checker();
    join_none
  endtask : execute


endclass : scoreboard

