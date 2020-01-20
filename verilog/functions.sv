package functions;

  function [31:0] multiplexer;
    input [31:0] data0;
    input [31:0] data1;
    input [0:0] sel;
    begin
      if (sel == 0)
        multiplexer = data0;
      else
        multiplexer = data1;
    end
  endfunction

endpackage
