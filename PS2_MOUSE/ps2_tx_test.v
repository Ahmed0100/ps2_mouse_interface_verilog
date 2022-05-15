module ps2_tx_test;
reg clk,reset,wr_ps2,ps2_c_in,ps2_d_in;
reg [7:0] din;

wire ps2_c_out,ps2_d_out,tx_idle,tx_done;



ps2_transmitter u1(clk,reset,wr_ps2,din,ps2_c_in,ps2_d_in,ps2_c_out,ps2_d_out,tx_idle,tx_done);



initial 
begin
	clk=0; reset=1; 
	ps2_c_in=0; ps2_d_in=0;
	#20 begin reset=0; wr_ps2=1; din=8'ha3; end


end
always 
#10 clk=!clk;
always
#200 ps2_c_in=!ps2_c_in;

endmodule