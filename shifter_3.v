module shifter15(shout, shin);
output [17:0] shout;
input [15:0] shin;
assign shout = shin << 2;
endmodule

