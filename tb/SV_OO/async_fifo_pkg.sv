/***********************************************************************
  $FILENAME    : async_fifo_pkg.svh

  $TITLE       : Package definition

  $DATE        : 11 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This package include some common code to be shared 
                 across multiple modules in the verification system. 

************************************************************************/


package async_fifo_pkg;

  // FIFO Data Bus Width
  parameter FIFO_DATA_WIDTH = 8;
  // FIFO Address Bus Width
  parameter FIFO_MEM_ADDR_WIDTH = 4;

  `include "coverage.svh"
  `include "tester.svh"
  `include "scoreboard.svh"
  `include "tb.svh"

endpackage : async_fifo_pkg

