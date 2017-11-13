/***********************************************************************
  $FILENAME    : tb.svh

  $TITLE       : Testbench module

  $DATE        : 11 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This module defines the high level tester module
                 which schedules the entire test scenario.

************************************************************************/


class tb;

  // Bus Functional Model interface
  virtual async_fifo_bfm bfm;

  tester     tester_h;
  coverage   coverage_h;
  scoreboard scoreboard_h;
   

  //
  // Class constructor method
  //
  function new (virtual async_fifo_bfm b);
    bfm = b;
  endfunction : new


  //
  // This method launches all the subcomponents of the testbench concurrently
  //
  task execute();
    tester_h     = new(bfm);
    coverage_h   = new(bfm);
    scoreboard_h = new(bfm);

    fork
      coverage_h.execute();
      scoreboard_h.execute();
      tester_h.execute();
      join_none
  endtask : execute

endclass : tb

