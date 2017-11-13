/***********************************************************************
  $FILENAME    : random_sequence.svh

  $TITLE       : Random sequence generator for FIFO verification

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This class utilises an instance of the sequence_item 
                 to serialize random values into FIFO.

************************************************************************/


class random_sequence extends uvm_sequence #(sequence_item);
  `uvm_object_utils(random_sequence);
  
  // UVM sequence item for input data flow into FIFO
  sequence_item fifo_push;

  //
  // Class constructor method
  //
  function new(string name = "random_sequence");
    super.new(name);
  endfunction : new


  //
  // Overrides UVM body method
  // This method initiates pushing a sequence of values continously 
  // into FIFO. The number of the iterations is determined 
  // by the TEST_NUM_ITER parameter.
  //
  integer i = 0;
  task body();
    repeat (TEST_NUM_ITER) begin : random_loop
      $display("%dns : random_sequence::iter# %2d", $time, i);
      fifo_push = sequence_item::type_id::create("fifo_push");
      start_item(fifo_push);
      assert(fifo_push.randomize());
      finish_item(fifo_push);
      i++;
    end : random_loop
  endtask : body


endclass : random_sequence

