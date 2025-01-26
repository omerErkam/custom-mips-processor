module control(in, regdest, alusrc, memtoreg, regwrite, 
	       memread, memwrite, brancheq, branchne, aluop1, aluop2, jump, jfor);

input [7:0] in;
output regdest, alusrc, memtoreg, regwrite, memread, memwrite, brancheq, branchne, aluop1, aluop2,jump,jfor;

wire rformat,lw,sw,beq,bne,addi,j,jalfor;

assign rformat = (~in[7]) & (in[6])  & (~in[5]) & (~in[4]) & (~in[3]) & (~in[2]) & (~in[1]) & (~in[0]);    	// 01000000 = 64
assign lw      = (~in[7]) & (in[6])  & (~in[5]) & (~in[4]) & (~in[3]) & (~in[2]) & (~in[1]) & (in[0]);    	// 01000001 = 65
assign sw      = (~in[7]) & (in[6])  & (~in[5]) & (~in[4]) & (~in[3]) & (~in[2]) & (in[1])  & (~in[0]);    	// 01000010 = 66
assign beq     = (~in[7]) & (in[6])  & (~in[5]) & (~in[4]) & (~in[3]) & (~in[2]) & (in[1])  & (in[0]);    	// 01000011 = 67
assign bne     = (~in[7]) & (in[6])  & (~in[5]) & (~in[4]) & (~in[3]) & (in[2])  & (~in[1]) & (~in[0]);    	// 01000100 = 68
assign addi    = (~in[7]) & (in[6])  & (~in[5]) & (~in[4]) & (~in[3]) & (in[2])  & (~in[1]) & (in[0]);    	// 01000101 = 69
assign j       = (~in[7]) & (in[6])  & (~in[5]) & (~in[4]) & (~in[3]) & (in[2])  & (in[1])  & (~in[0]);    	// 01000110 = 70
assign jalfor  = (~in[7]) & (in[6])  & (~in[5]) & (~in[4]) & (~in[3]) & (in[2])  & (in[1])  & (in[0]);    	// 01000111 = 71

assign regdest = rformat;
assign alusrc = lw|sw|addi;
assign memtoreg = lw;
assign regwrite = (rformat|lw|addi);
assign memread = lw;
assign memwrite = sw;
assign brancheq = beq;
assign branchne = bne;
assign aluop1 = rformat;
assign aluop2 = beq|bne;
assign jfor = jalfor;
assign jump = jalfor|j;

endmodule

