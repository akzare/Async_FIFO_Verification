/***********************************************************************
  $FILENAME    : driver.svh

  $TITLE       : Driver class that initiate requests for new transactions

  $DATE        : 11 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This class implements the push/pop methods on FIFO.

************************************************************************/


class driver extends uvm_driver #(sequence_item);
  `uvm_component_utils(driver)

  // Bus Functional Model interface
  virtual async_fifo_bfm bfm;


  //
  // Class constructor method
  //
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new


  //
  // Overrides UVM build_phase method
  // The testbench component hierarchy is constructed by this method.
  //
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual async_fifo_bfm)::get(null, "*", "bfm", bfm))
      `uvm_fatal("DRIVER", "driver::Failed to get BFM")
  endfunction : build_phase


  //
  // Pushing data into FIFO
  // This method pushes a sequence of values continously into FIFO 
  // unless FIFO gets full. The length of this sequence is determined 
  // by the TEST_FLOW_LENGTH parameter.
  //
  task push();
  begin
    sequence_item push;
    integer i = 0;
    forever begin : push_loop
      if (i < TEST_FLOW_LENGTH-2) begin
        seq_item_port.get_next_item(push);
        bfm.push(push.wdata, 1'b0);
        $display("%dns : driver::push::iter# %2d   wdata %2h", $time, i, push.wdata);
        seq_item_port.item_done();
      end else begin
        seq_item_port.get_next_item(push);
        bfm.push(push.wdata, 1'b1);
        $display("%dns : driver::push::iter# %2d   wdata %2h", $time, i, push.wdata);
        seq_item_port.item_done();
      end
      i++;
      if (i > TEST_FLOW_LENGTH-1) i = 0;
    end : push_loop
  end
  endtask : push


  //
  // Poping data from FIFO
  // This method pops a sequence of values continously out of FIFO 
  // unless FIFO gets empty. The length of this sequence is determined 
  // by the TEST_FLOW_LENGTH parameter.
  //
  task pop();
  begin
    integer i = 0;
    forever begin : pop_loop
      if (i < TEST_FLOW_LENGTH-2) begin
        bfm.pop(1'b0);
      end else begin
        bfm.pop(1'b1);
      end
      i++;
      if (i > TEST_FLOW_LENGTH-1) i = 0;
    end : pop_loop
  end
  endtask : pop


  //
  // Overrides UVM run_phase method
  // This method runs in parallel across all the processes.
  // It is used for the stimulus generation and checking activities of the Testbench.
  //
  task run_phase(uvm_phase phase);

    // Reset FIFO
    bfm.reset_rdwr();
    // Lunch both push and pop processes concurrently
    fork
      push();
      pop();
    join_none

  endtask : run_phase


endclass : driver

