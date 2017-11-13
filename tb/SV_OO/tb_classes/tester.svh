/***********************************************************************
  $FILENAME    : tester.svh

  $TITLE       : Tester module

  $DATE        : 11 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This module defines the high level tester module
                 which schedules the entire test scenario.

************************************************************************/


class tester;

  // Bus Functional Model interface
  virtual async_fifo_bfm bfm;


  //
  // Class constructor method
  //
  function new (virtual async_fifo_bfm b);
    bfm = b;
  endfunction : new


  //
  // This method forks the Push/Pop methods to run the data flow to/from
  // FIFO.
  //
  task execute();
  begin
    // Assert reset first
    bfm.reset_rdwr();

    $write("%dns : tester::Starting Pop & Push generators in bfm\n", $time);
    fork
      bfm.genPush();
      bfm.genPop(); 
    join_none

    bfm.wait_4_rdwr_done();
    $write("%dns : tester::Terminating simulations\n", $time);
    $stop;
  end
  endtask : execute

endclass : tester

