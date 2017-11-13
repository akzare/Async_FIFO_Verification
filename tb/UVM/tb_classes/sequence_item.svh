/***********************************************************************
  $FILENAME    : sequence_item.svh

  $TITLE       : UVM sequence_item generator for input data flow to FIFO

  $DATE        : 12 Nov 2017

  $VERSION     : 1.0.0

  $DESCRIPTION : Defines some operations to generate some random sequence 
                 of data for supplying to the input of FIFO.

************************************************************************/


class sequence_item extends uvm_sequence_item;
  `uvm_object_utils(sequence_item);


  //
  // Class constructor method
  //
  function new(string name = "");
    super.new(name);
  endfunction : new

  // Randomized input data flow into FIFO
  rand logic [FIFO_DATA_WIDTH-1:0] wdata;

  constraint data { wdata dist {8'h00:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};} 

   
  //
  // Overrides UVM do_compare method
  //
  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    sequence_item tested;
    bit           same;
      
    if (rhs==null) `uvm_fatal(get_type_name(), 
                               "sequence_item::Tried to do comparison to a null pointer");
      
    if (!$cast(tested, rhs))
      same = 0;
    else
      same = super.do_compare(rhs, comparer) && 
                             (tested.wdata == wdata);
    return same;
  endfunction : do_compare


  //
  // Overrides UVM do_copy method
  //
  function void do_copy(uvm_object rhs);
    sequence_item RHS;
    assert(rhs != null) else
        $fatal(1, "sequence_item::Tried to copy null transaction");
    super.do_copy(rhs);
    assert($cast(RHS, rhs)) else
        $fatal(1, "sequence_item::Failed cast in do_copy");
    wdata = RHS.wdata;
  endfunction : do_copy


  //
  // Overrides UVM convert2string method
  //
  function string convert2string();
    string s;
    s = $sformatf("wdata: %2h", wdata);
    return s;
  endfunction : convert2string

endclass : sequence_item

