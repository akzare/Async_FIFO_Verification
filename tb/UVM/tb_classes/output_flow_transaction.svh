/***********************************************************************
  $FILENAME    : output_flow_transaction.svh

  $TITLE       : User defined transaction class on FIFO output data flow

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : This class provides the transaction recording support
                 on the output data flow of the FIFO

************************************************************************/


class output_flow_transaction extends uvm_transaction;

  // Read data value out of FIFO
  logic [FIFO_DATA_WIDTH-1:0] rdata;


  //
  // Class constructor method
  //
  function new(string name = "");
    super.new(name);
  endfunction : new


  //
  // Overrides UVM do_copy method
  // This method is used to copy all the properties of a output_flow_transaction
  // object. 
  //
  function void do_copy(uvm_object rhs);
    output_flow_transaction copied_transaction_h;
    assert(rhs != null) else
        $fatal(1, "output_flow_transaction::Tried to copy null transaction");
    super.do_copy(rhs);
    assert($cast(copied_transaction_h,rhs)) else
        $fatal(1, "output_flow_transaction::Faied cast in do_copy");
    rdata = copied_transaction_h.rdata;
  endfunction : do_copy


  //
  // Overrides UVM convert2string method
  // This method is used to convert each property of the output_flow_transaction 
  // object into a string.
  //
  function string convert2string();
    string s;
    s = $sformatf("rdata: %2h", rdata);
    return s;
  endfunction : convert2string


  //
  // Overrides UVM do_compare method
  // This method is used to compare each property of the output_flow_transaction object.
  //
  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    output_flow_transaction RHS;
    bit    same;
    assert(rhs != null) else
        $fatal(1, "output_flow_transaction::Tried to copare null transaction");

    same = super.do_compare(rhs, comparer);

    $cast(RHS, rhs);
    same = (rdata == RHS.rdata) && same;
    return same;
  endfunction : do_compare


endclass : output_flow_transaction

