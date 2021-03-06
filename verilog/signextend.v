`timescale 1ns/1ps
module signextend
#(parameter width = 15)
(
  input [width:0] unextended,
  //output [31:0] extended,
  output reg[31:0] shifted
);

	reg [31:0] extended;

  //assign extended = {{16{unextended[15]}}, {unextended[15:0]}};
  initial begin 
    extended <= $signed(unextended);
    shifted <= extended<<2;
  end
endmodule