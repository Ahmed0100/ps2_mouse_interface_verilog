module mouse_interface_test;

integer i=0;
reg clk,reset,ps2_c_in,ps2_d_in;
wire [8:0] xm,ym;
wire [2:0] button;
wire mouse_done;
wire ps2_d_out,ps2_c_out;
wire [2:0] state_reg;

mouse_interface u1(clk,reset,ps2_c_in,ps2_d_in,ps2_c_out,ps2_d_out,xm,ym,button,mouse_done,state_reg);

initial 
begin
	clk=0; reset=1; 
	ps2_c_in=0; ps2_d_in=0;
	#20 begin reset=0; end
	 
end

always  
#400 begin if(state_reg>=4)
ps2_d_in=i;
i=i+1;  end

always 
#10 clk=!clk;
always
#200 ps2_c_in=!ps2_c_in;

endmodule
