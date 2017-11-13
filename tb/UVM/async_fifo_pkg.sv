/***********************************************************************
  $FILENAME    : async_fifo_pkg.svh

  $TITLE       : Package definition

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This package include some common code to be shared 
                 across multiple modules in the verification system. 

************************************************************************/


package async_fifo_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // FIFO Data Bus Width
  parameter FIFO_DATA_WIDTH = 8;
  // FIFO Address Bus Width
  parameter FIFO_MEM_ADDR_WIDTH = 4;
  // Length of Input/Output Data Flow to/from FIFO
  parameter TEST_FLOW_LENGTH = 25;
  // Number of test iterations
  parameter TEST_NUM_ITER = 30;


  `include "sequence_item.svh"
  // sequencer definition
  typedef uvm_sequencer #(sequence_item) sequencer;

  `include "random_sequence.svh"
  `include "runall_sequence.svh"

  `include "output_flow_transaction.svh"
  `include "coverage.svh"
  `include "scoreboard.svh"
  `include "driver.svh"
  `include "input_flow_monitor.svh"
  `include "output_flow_monitor.svh"

  `include "env.svh"

  `include "async_fifo_base_test.svh"
  `include "full_test.svh"

endpackage : async_fifo_pkg

