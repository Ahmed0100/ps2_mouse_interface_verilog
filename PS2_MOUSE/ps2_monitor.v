module ps2_monitor(clk,reset,wr_ps2,ps2_c,ps2_d,sw,tx);
input clk,reset,wr_ps2;
inout ps2_c,ps2_d;
input [7:0] sw;
output wire tx;
reg wr_uart;
reg [7:0] wr_data;
localparam [1:0] 
idle =2'b00,
send1=2'b01,
send0=2'b10,
sendb=2'b11;

wire [7:0] rx_data;
localparam [7:0] sp=8'h20;
reg [7:0] ascii_code;
wire  [3:0] hex_in;

ps2_rx_tx u1(.clk(clk),.reset(reset),.wr_ps2(wr_ps2),.din(sw),.ps2_c(ps2_c),.ps2_d(ps2_d),.dout(rx_data),.tx_done()
,.rx_done(rx_done));

uart u2(.clk(clk),.reset(reset),.rd_uart(1'b0),.rx_empty(),.wr_uart(wr_uart),.tx_full(),.rd_data(),.wr_data(wr_data),
.tx(tx),.rx(1'b1));


reg [1:0] state_reg,state_next;

always @(posedge clk or posedge reset)
	if(reset)
		state_reg=idle;
	else
		state_reg=state_next;

//next state logic
always @* 
	begin
	state_next=state_reg;
	wr_uart=0;
	wr_data=sp;
	case(state_reg)
		idle: 
			if(rx_done)
				state_next=send1;
		send1: 
			begin
			wr_uart=1;
			wr_data=ascii_code;
			state_next=send0;

			end
		send0: 
			begin
			wr_uart=1;
			wr_data=ascii_code;
			state_next=sendb;
			end


		sendb:
			begin
			wr_uart=1;
			wr_data=sp;
			state_next=idle;
			end
	endcase
end

assign hex_in=(state_reg==send1)?  rx_data[7:4]:rx_data[3:0];

always @*
case(hex_in)
4'h0:  ascii_code  =8'h30; 
4'h1:  ascii_code  =8'h31;
4'h2:  ascii_code  =8'h32; 
4'h3:  ascii_code  =  8'h33; 
4'h4:  ascii_code  =  8'h34; 
4'h5:  ascii_code  =  8'h35; 
4'h6:  ascii_code  =  8'h36; 
4'h7:  ascii_code  =  8'h37; 
4'h8:  ascii_code  =  8'h38; 
4'h9:  ascii_code  =  8'h39; 
4'ha:  ascii_code  =  8'h41; 
4'hb:  ascii_code  =  8'h42; 
4'hc:  ascii_code  =  8'h43; 
4'hd:  ascii_code  =  8'h44; 
4'he:  ascii_code  =  8'h45; 
default  :  ascii_code  =  8'h46; 
endcase
endmodule   


