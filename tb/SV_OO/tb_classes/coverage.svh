/***********************************************************************
  $FILENAME    : coverage.svh

  $TITLE       : Coverage class implementation

  $DATE        : 11 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : The coverage class provides all the necessary methods
                 in order to performe the functional coverage.

************************************************************************/


class coverage;

  // Bus Functional Model interface
  virtual async_fifo_bfm bfm;

  logic [FIFO_DATA_WIDTH-1:0] wdata;

  //
  // Coverage group definition
  //
  covergroup wdata_cov;

    write_data: coverpoint wdata {
      bins zeros = {'h00};
      bins others= {['h01:'hFE]};
      bins ones  = {'hFF};
    }

  endgroup


  //
  // Class constructor method
  //
  function new (virtual async_fifo_bfm b);
    wdata_cov = new();
    bfm = b;
  endfunction : new


  //
  // Execute method
  //
  task execute();
    forever begin : sampling_block
      @(posedge bfm.winc);
      wdata = bfm.wdata;
      wdata_cov.sample();
    end : sampling_block
  endtask : execute


endclass : coverage

