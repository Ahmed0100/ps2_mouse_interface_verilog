module mouse_interface(clk,reset,ps2_c_in,ps2_d_in,ps2_c_out,ps2_d_out,xm,ym,button,mouse_done,state_reg);
input clk,reset;
input ps2_c_in,ps2_d_in;
output wire ps2_c_out,ps2_d_out;
output wire [8:0] xm,ym;
output wire [2:0] button;
output reg mouse_done;
localparam stream_cmd =8'hf4;


localparam [2:0] 
init1=3'b000,
init2=3'b001,
init3=3'b010,
pack1=3'b011,
pack2=3'b100,
pack3=3'b101,
done=3'b110;

reg [8:0] x_reg,x_next,y_reg,y_next;
reg [2:0] button_reg,button_next;

output reg [2:0] state_reg;
reg [2:0] state_next;
wire tx_done,rx_done;
reg wr_ps2;
wire [7:0] rx_data;

ps2_rx_tx  u1 (.clk(clk),.reset(reset),.wr_ps2(wr_ps2),.din(stream_cmd),.ps2_c_in(ps2_c_in),.ps2_d_in(ps2_d_in),
.ps2_c_out(ps2_c_out),.ps2_d_out(ps2_d_out),.dout(rx_data),.tx_done(tx_done),.rx_done(rx_done));

always @(posedge clk or posedge reset)	
	if(reset)
		begin
		state_reg=init1;
		x_reg=0;
		y_reg=0;
		button_reg=0;
		end
	else 
		begin
		state_reg=state_next;
		x_reg=x_next;
		y_reg=y_next;
		button_reg=button_next;
		end
	
always @*
	begin
	state_next=state_reg;
	x_next=x_reg;
	y_next=y_reg;
	button_next=button_reg;
	mouse_done=0;
	case(state_reg)
		init1: 
			begin
			wr_ps2=1;
			state_next=init2;
			end
		init2:
			
			if(tx_done==1)
			state_next=init3;
		init3: 
			if(rx_done)
			state_next=pack1;
		pack1: 
			
			if(rx_done)
				begin
				y_next[8]=rx_data[5];
				x_next[8]=rx_data[4];
				button_next=rx_data[2:0];
				state_next=pack2;
				end	
		pack2:
			if(rx_done)
				begin
				y_next[7:0]=rx_data;
				state_next=pack3;
				end
		pack3: 
			if(rx_done)
				begin
				x_next[7:0]=rx_data;
				state_next=done;
				end
		endcase
		end
assign xm=x_reg;
assign ym=y_reg;
assign button=button_reg;
endmodule 
	

	
			
			
