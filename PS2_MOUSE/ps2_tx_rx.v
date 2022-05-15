module ps2_rx_tx(clk,reset,wr_ps2,din,ps2_c_in,ps2_d_in,ps2_c_out,ps2_d_out,dout,tx_done,rx_done);
input clk,reset,wr_ps2;
input [7:0] din;

input ps2_d_in,ps2_c_in;
output wire ps2_c_out,ps2_d_out;
output wire [7:0] dout;
output wire tx_done,rx_done;

wire tx_idle;

ps2_transmitter u1(clk,reset,wr_ps2,din,ps2_c_in,ps2_d_in,ps2_c_out,ps2_d_out,tx_idle,tx_done);

 ps2_receiver u2(.clk(clk),.reset(reset),.rx_en(~tx_idle),.ps_c(ps2_c_in),.ps_d(ps2_d_in),.rx_done_tick(rx_done),.dout(dout));
 


endmodule 
