/***********************************************************************
  $FILENAME    : coverage.svh

  $TITLE       : Coverage class implementation

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : The coverage class provides all the necessary methods
                 in order to performe the functional coverage.

************************************************************************/


class coverage extends uvm_subscriber #(sequence_item);
  `uvm_component_utils(coverage)

  // FIFO input write data
  logic [FIFO_DATA_WIDTH-1:0] wdata;

  //
  // Coverage group definition
  //
  covergroup wdata_cov;
    // FIFO write data coverage
    write_data: coverpoint wdata {
      bins zeros = {'h00};
      bins others= {['h01:'hFE]};
      bins ones  = {'hFF};
    }
  endgroup



  //
  // Class constructor method
  //
  function new (string name, uvm_component parent);
    super.new(name, parent);
    wdata_cov = new();
  endfunction : new


  //
  // Overrides UVM write method
  // write method: Receives date from command_monitor
  //
  function void write(sequence_item t);
    wdata = t.wdata;
    wdata_cov.sample();
  endfunction : write

endclass : coverage

