module alucont(aluop1,aluop0,f3,f2,f1,f0,gout);
input aluop1,aluop0,f3,f2,f1,f0;
output [2:0] gout;
reg [2:0] gout;

always @(aluop1 or aluop0 or f3 or f2 or f1 or f0)
begin
	if(~(aluop1|aluop0)) // 00
		gout=3'b110; //add
	if(aluop0)	     // beq or bne
		gout=3'b100; // sub
	
	if(aluop1) //r-type
	begin
		if (~(f3|f2|f1)&f0) //0001
			gout=3'b001; //sll
		if (~(f3|f2|f0)&f1) //0010
			gout=3'b010; //srl
		if (~(f3|f2)&f1&f0) //0011
			gout=3'b011; //nor
		if (~(f3|f1|f0)&f2) //0100
			gout=3'b100; //sub
		if (~(f3|f1)&f2&f0) //0101
			gout=3'b101; //or
		if (~(f3|f0)&f2&f1) //0110
			gout=3'b110; //add

	end
end
endmodule

