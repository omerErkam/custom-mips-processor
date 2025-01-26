module processor;

reg clk;

reg [31:0] pc;

reg [7:0] datmem[0:63], mem[0:31];

wire [31:0] dataa,datab;

wire [31:0] out2,out3,out4,out6; 

wire [31:0] sum, extad, adder1out, adder2out, sextad, readdata,jump_address_j,jump_address_jfor;
wire [23:0] inst23_0; // J type
wire [7:0] inst31_24; // opcode
wire [3:0] inst23_20, inst19_16, inst15_12, out1;
wire [5:0] inst11_6, inst5_0; // R type
wire [15:0] inst15_0;
wire [31:0] instruc,dpack;
wire [2:0] gout;
wire [25:0] jump_ext;

wire cout,zout,nout,pcsrc,regdest,alusrc,memtoreg,regwrite,memread,
memwrite,brancheq, branchne, aluop1,aluop0,jump,jfor;


reg [31:0] registerfile [0:15]; // 16 registers with 32 bits long.
//integer i;
integer i, c;
reg [31:0] t_mem; 

// datamemory connections
always @(posedge clk)
begin
	if(memwrite)
	begin 
		datmem[sum[5:0]+3] <= datab[7:0];
		datmem[sum[5:0]+2] <= datab[15:8];
		datmem[sum[5:0]+1] <= datab[23:16];
		datmem[sum[5:0]] <= datab[31:24];
	end
end

//instruction memory
assign instruc = {mem[pc[4:0]],
		  mem[pc[4:0]+1],
                  mem[pc[4:0]+2],
 		  mem[pc[4:0]+3]};

assign inst31_24 = instruc[31:24]; // opcode
assign inst23_20 = instruc[23:20];
assign inst19_16 = instruc[19:16]; 
assign inst15_12 = instruc[15:12];
assign inst11_6 = instruc[11:6];   
assign inst5_0 = instruc[5:0];    
assign inst15_0 = instruc[15:0];   // immediate-address
assign inst23_0 = instruc[23:0];   // j address

// registers
assign dataa = (aluop1&(instruc[11] | instruc[10] | instruc[9] | instruc[8] | instruc[7] | instruc[6])) ? registerfile[inst19_16] : registerfile[inst23_20];
assign datab = (aluop1&(instruc[11] | instruc[10] | instruc[9] | instruc[8] | instruc[7] | instruc[6])) ? inst11_6 : registerfile[inst19_16];

//multiplexers
assign dpack={	datmem[sum[5:0]],
	      		datmem[sum[5:0]+1],
	      		datmem[sum[5:0]+2],
        		datmem[sum[5:0]+3]	};

//jal and j instructions jump_address calculation
shifter shifter1(jump_ext,inst23_0);
assign jump_address_j = {pc[31:26],jump_ext};

//module mult2_to_1_5(out,i0,i1,s0);
mult2_to_1_4  mult1(out1, instruc[19:16],instruc[15:12],regdest);
mult2_to_1_32 mult2(out2, datab, extad, alusrc);
mult2_to_1_32 mult3(out3, sum, dpack, memtoreg);
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);
//mult2_to_1_32 mult5(out5, out3,adder1out,jal);
mult2_to_1_32 mult6(out6, out4,jump_address_j,jump);

always @(posedge clk)
begin
	registerfile[out1]= regwrite ? out3 : registerfile[out1];
end

always @(posedge clk)
begin

        	pc = out6;
    	
end

// alu, adder and control logic connections

alu32 alu1(sum, dataa, out2, zout, gout);
adder add1(pc,32'h4,adder1out);
adder add2(adder1out,sextad,adder2out);
/*
control(in, regdest, alusrc, memtoreg, regwrite, memread, memwrite, brancheq, aluop1, aluop2);
*/
control cont(instruc[31:24],regdest,alusrc,memtoreg,regwrite,memread,memwrite, brancheq, branchne, aluop1,aluop0,jump,jfor);

signext sext(instruc[15:0],extad);

alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0],gout);

shift shift2(sextad,extad);

assign pcsrc = ((brancheq & zout) | (branchne & (~zout)));

//initialize datamemory,instruction memory and registers
initial
begin
	$readmemh("initDataMemory.dat",datmem);
	$readmemh("initIM.dat",mem);
	$readmemh("initRegisterMemory.dat",registerfile);

	//for(i=0; i<31; i=i+1)
	//$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	//"Register[%0d]= %h",i,registerfile[i]);

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= 0x%h   ",i,datmem[i], 
	"Register[%0d]= 0x%h ",i,registerfile[i]);
    	c = 0;
    	t_mem = 0;

    	for (i = 0; i < 31; i = i + 1) begin
      	t_mem = {t_mem[23:0], mem[i]}; 
      	c = c + 1;
	      	if (c == 4) begin
			c = 0;
			$display("Instruction Memory[%0d]= 0x%h [%b %b %b %b %b %b %b]", 
		          i - 3, t_mem,
		          t_mem[31:24], t_mem[23:20], 
		          t_mem[19:16], t_mem[15:12],
				  t_mem[11:6], t_mem[5:0],
				  t_mem[15:0]);
			t_mem = 0; 
	      	end
    	end

end

initial
begin
	pc=0;
	#500 $finish;
end

initial
begin
	clk=0;
forever #20  clk=~clk;
end

initial 
begin
	//$monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
	//"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
	$monitor($time," PC %h [%d]",pc,pc,"  SUM %h",sum,"   INST %h [%b %b %b %b %b %b %b]",instruc[31:0], inst31_24,inst23_20,inst19_16,inst15_12,inst11_6,inst5_0,inst15_0,
	"   REGISTER %h %h %h %h %p DATA MEMORY %p",registerfile[4],registerfile[5], registerfile[6],registerfile[1], registerfile,datmem );


end

endmodule

