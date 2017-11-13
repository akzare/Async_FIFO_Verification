/***********************************************************************
  $FILENAME    : async_fifo_bfm.svh

  $TITLE       : Bus Functional Model (BFM) interface definition

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This module defines DUT's BFM interface which includes 
                 the FIFO (DUT) interface and also the required methods
                 for pushing/poping data to/from it.

************************************************************************/


interface async_fifo_bfm;
  import async_fifo_pkg::*;

  //
  // DUT interface section
  //
  bit winc;
  bit wclk;
  bit wrst_n;
  bit rinc;
  bit rclk;
  bit rrst_n;
  logic [FIFO_DATA_WIDTH-1:0] wdata;

  wire [FIFO_DATA_WIDTH-1:0] rdata;
  wire wfull;
  wire rempty;


  //
  // Internal signals section
  //

  // Indicates the moment when all the push transactions are finished
  bit rdDone;
  // Indicates the moment when all the pop transactions are finished
  bit wrDone;

  // Number of write transactions to FIFO
  integer wr_cmds;
  // Number of read transactions from FIFO
  integer rd_cmds;


  //
  // Reset input/output interfaces of FIFO
  //
  task reset_rdwr();
  begin
    $write("%dns : bfm::Asserting reset on both read/write sides\n", $time);
    winc = 1'b0;
    wdata = '0;
    wrst_n = 1'b0;
    rinc = 1'b0;
    rrst_n = 1'b0;
    repeat(5) @(posedge wclk);
    wrst_n = 1'b1;
    repeat(1) @(posedge rclk);
    #2
    rrst_n = 1'b1;
    repeat(2) @(posedge rclk);
    $write("%dns : bfm::Done asserting reset on both read/write sides\n", $time);
  end
  endtask : reset_rdwr


  //
  // Pushing data into FIFO
  //
  task push(input bit [FIFO_DATA_WIDTH-1:0] data, input bit last);
  begin
    @ (negedge wclk);
    while (wfull == 1'b1) begin
      winc  = 1'b0;
      wdata = {(FIFO_DATA_WIDTH){1'b0}};
      @ (negedge wclk); 
    end
    winc  = 1'b1;
    wdata = data;
    $display("%dns : bfm::Pushing %h to FIFO", $time, wdata);

    if (last) begin
      @ (negedge wclk);
      winc  = 1'b0;
      wdata= {(FIFO_DATA_WIDTH){1'b0}};

      repeat (10) @ (posedge wclk);
      wrDone = 1;
    end
  end
  endtask : push


  //
  // Poping data from FIFO
  //
  task pop(input bit last);
  begin
     @ (posedge rclk);
     while (rempty == 1'b1) begin
       rinc = 1'b0;
       @ (posedge rclk); 
     end
     rinc = 1'b1;

    if (last) begin
      @ (posedge rclk);
      rinc = 1'b0;
      repeat (10) @ (posedge rclk);
      rdDone = 1;
    end
  end
  endtask : pop


  //
  // Waiting until the verification system finishes all the Push/Pop transactions
  //
  task wait_4_rdwr_done();
  begin
    while (!wrDone) begin
      @ (posedge wclk);
    end
    while (!rdDone) begin
      @ (posedge rclk);
    end
  end
  endtask : wait_4_rdwr_done
   



  input_flow_monitor input_flow_monitor_h;

  //
  // This method monitors the input data flow into FIFO and writes
  // each input into input_flow_monitor module.
  //
  initial begin : input_flow_monitor_thread
    forever begin : input_flow_monitor_block
      @ (posedge bfm.wclk iff bfm.winc);
      if (input_flow_monitor_h != null)
        input_flow_monitor_h.write_to_monitor(bfm.wdata);
      $display("%dns : bfm::Monitoring wdata = %h", $time, bfm.wdata);
    end : input_flow_monitor_block
  end : input_flow_monitor_thread


   
  output_flow_monitor output_flow_monitor_h;

  //
  // This method monitors the output data flow from FIFO and writes
  // each output into output_flow_monitor module.
  //
  initial begin : output_flow_monitor_thread
    forever begin : output_flow_monitor_block
      @ (negedge bfm.rclk iff bfm.rinc);
      if (output_flow_monitor_h != null)
        output_flow_monitor_h.write_to_monitor(bfm.rdata);
      $display("%dns : bfm::Monitoring rdata = %h", $time, bfm.rdata);
    end : output_flow_monitor_block
  end : output_flow_monitor_thread

   
  //
  // Clock generator
  //
  initial begin
    wclk = 1'b0;
    rclk = 1'b0;

    fork
      forever #10ns wclk = ~wclk; // Fast clock zone
      forever #35ns rclk = ~rclk; // Slow clock zone
    join
  end

endinterface : async_fifo_bfm

