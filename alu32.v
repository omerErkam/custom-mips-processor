module alu32(alu_out, a, b, zout, alu_control);
output reg [31:0] alu_out;
input [31:0] a,b;
input [2:0] alu_control;

reg [31:0] less;
output zout;
reg zout;

always @(a or b or alu_control)
begin
	case(alu_control)
	3'b001: alu_out = a << b; // shift left
	3'b010: alu_out = a >> b; // shift right
	3'b011: alu_out = ~(a | b); // nor
	3'b100: alu_out = a+1+(~b); // sub
	3'b101: alu_out = a | b; // or
	3'b110: alu_out = a+b; // add
	default: alu_out=31'bx;
	endcase
zout=~(|alu_out);
end
endmodule