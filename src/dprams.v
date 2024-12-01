
module DLROM #(parameter AW=0,parameter DW=0)
(
	input							CL0,
	input [(AW-1):0]			AD0,
	output reg [(DW-1):0]	DO0,

	input							CL1,
	input [(AW-1):0]			AD1,
	input	[(DW-1):0]			DI1,
	input							WE1
);

reg [(DW-1):0] core[0:((2**AW)-1)] /* synthesis ramstyle = "no_rw_check, M10K" */;

always @(posedge CL0) DO0 <= core[AD0];
always @(negedge CL1) if (WE1) core[AD1] <= DI1;

endmodule


module LBUF1024_8
(
	input				CL0,
	input  [9:0]	AD0,
	input				WE0,
	input	 [7:0]	WD0,

	input				CL1,
	input  [9:0]	AD1,
	input				RE1,
	input				WE1,
	input	 [7:0]	WD1,
	output [7:0]	DT1
);

wire re0 = 1'b0;
wire [7:0] dt0;

/*DPRAM1024 core
(
	AD0,AD1,
	CL0,CL1,
	WD0,WD1,
	re0,RE1,
	WE0,WE1,
	dt0,DT1
);*/

// Simulating byte enable functionality with write enable logic 
wire [0:0] byteena_a = 1'b1;
wire [0:0] byteena_b = 1'b1;

// Xilinx dual-port RAM instance
xpm_memory_tdpram #(
    .MEMORY_SIZE        (8192),        // Memory size in bits / 8 = 1024 words
    .MEMORY_PRIMITIVE   ("auto"),
    .CLOCKING_MODE      ("independent_clock"),
    .MEMORY_INIT_FILE   ("none"),
    .MEMORY_INIT_PARAM  ("0"),
    .USE_MEM_INIT       (1),
    .WAKEUP_TIME        ("disable_sleep"),
    .MESSAGE_CONTROL    (0),
    .ECC_MODE           ("no_ecc"),
    .AUTO_SLEEP_TIME    (0),
    .WRITE_DATA_WIDTH_A (8),
    .READ_DATA_WIDTH_A  (8),
    .BYTE_WRITE_WIDTH_A (8),
    .ADDR_WIDTH_A       (10),
    .READ_RESET_VALUE_A ("0"),
    .READ_LATENCY_A     (1),
    .WRITE_MODE_A       ("write_first"),
    .WRITE_DATA_WIDTH_B (8),
    .READ_DATA_WIDTH_B  (8),
    .BYTE_WRITE_WIDTH_B (8),
    .ADDR_WIDTH_B       (10),
    .READ_RESET_VALUE_B ("0"),
    .READ_LATENCY_B     (1),
    .WRITE_MODE_B       ("write_first")
) core (
    .clka       (CL0),
    .rsta       (1'b0),
    .ena        (1'b1),
    .wea        (WE0 & byteena_a),
    .addra      (AD0),
    .dina       (WD0),
    .douta      (dt0),
    .clkb       (CL1),
    .rstb       (1'b0),
    .enb        (1'b1),
    .web        (WE1 & byteena_b),
    .addrb      (AD1),
    .dinb       (WD1),
    .doutb      (DT1)
);


endmodule

module DPRAM #(AW=8,DW=8)
(
	input 					CL0,
	input [AW-1:0]			AD0,
	input [DW-1:0]			WD0,
	input						WE0,
	output reg [DW-1:0]	RD0,

	input 					CL1,
	input [AW-1:0]			AD1,
	input [DW-1:0]			WD1,
	input						WE1,
	output reg [DW-1:0]	RD1
);

reg [7:0] core[0:((2**AW)-1)];

always @(posedge CL0) begin
	if (WE0) core[AD0] <= WD0;
	else RD0 <= core[AD0];
end

always @(posedge CL1) begin
	if (WE1) core[AD1] <= WD1;
	else RD1 <= core[AD1];
end

endmodule


module DPRAMrw #(AW=8,DW=8)
(
	input 					CL0,
	input [AW-1:0]			AD0,
	output reg [DW-1:0]	RD0,

	input 					CL1,
	input [AW-1:0]			AD1,
	input [DW-1:0]			WD1,
	input						WE1,
	output reg [DW-1:0] 	RD1
);

reg [7:0] core[0:((2**AW)-1)];

always @(posedge CL0) RD0 <= core[AD0];
always @(posedge CL1) if (WE1) core[AD1] <= WD1; else RD1 <= core[AD1];

endmodule


module RAM_B #(AW=8)
(
	input					cl,
	input	 [(AW-1):0]	ad,
	input   [7:0]		id,
	input					wr,
	output reg [7:0]	od
);

reg [7:0] core [0:((2**AW)-1)];

always @( posedge cl ) begin
	if (wr) core[ad] <= id;
	else od <= core[ad];
end

endmodule
