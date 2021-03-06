/***********************************************************************
  $FILENAME    : top.svh

  $TITLE       : Top hierarchy module

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This module defines the top hierarchy module of the system.

************************************************************************/


module top;
  import uvm_pkg::*;
  import   async_fifo_pkg::*;
  `include "uvm_macros.svh"
   
  //
  // Instantiate Bus Functional Model (BFM) interface
  //
  async_fifo_bfm bfm();

  //
  // Instantiate FIFO (DUT)
  //
  async_fifo #(FIFO_DATA_WIDTH, FIFO_MEM_ADDR_WIDTH) DUT
                 (.winc(bfm.winc),
                  .wclk(bfm.wclk),
                  .wrst_n(bfm.wrst_n),
                  .rinc(bfm.rinc),
                  .rclk(bfm.rclk),
                  .rrst_n(bfm.rrst_n),
                  .wdata(bfm.wdata),
                  .rdata(bfm.rdata),
                  .wfull(bfm.wfull),
                  .rempty(bfm.rempty));


  //
  // Run test -> full_test
  //
  initial begin
    uvm_config_db #(virtual async_fifo_bfm)::set(null, "*", "bfm", bfm);
    run_test("full_test");
  end


  //
  // Dump the changes in the values of nets and registers in async_fifo.vcd
  //
  initial begin
    $dumpfile("async_fifo.vcd");
    $dumpvars();
  end

endmodule : top

