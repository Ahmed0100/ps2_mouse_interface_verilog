
module uart_receiver#(parameter dbits=8,sb_ticks=16)
(input wire clk, reset,rx,s_ticks,
output reg rx_done_tick,
output wire [7:0] dout);
localparam [1:0]
idle=2'b00,
start=2'b01,
data=2'b10,
stop=2'b11;

reg  [1:0] state_reg,state_next;
reg [3:0] s_reg,s_next;
reg [3:0] n_reg,n_next;
reg [7:0] b_reg,b_next;

always @(posedge clk or posedge reset)
	if(reset)
	begin
		s_reg=0;
		b_reg=0;
		n_reg=0;
		state_reg=idle;
	end
	else
	begin
		
		s_reg=s_next;
		b_reg=b_next;
		n_reg=n_next;
		state_reg=state_next;
	end

		
always @*
begin
	state_next=state_reg;
	s_next=s_reg;
	b_next=b_reg;
	n_next=n_reg;
	rx_done_tick=0;
	case(state_reg)
		idle:
			if(~rx) 
			begin
				state_next=start;
				s_next=0;
			end
		start: 
			if(s_ticks)
				if(s_reg==7)
				begin
					state_next=data;
					s_next=0;
					n_next=0;
			
				end
			else 
				s_next=s_reg+1;
		data: 
			if(s_ticks)
				if(s_reg==15)
				begin 
					s_next=0;
					b_next={rx,b_reg[7:1]};
					if(n_reg==(dbits-1))
						state_next=stop;
					else 
						n_next=n_reg+1;
				end
				else 
					s_next=s_reg+1;
		stop:
			if(s_ticks)
				if(s_reg==(sb_ticks-1))
					begin
						state_next=idle;
						rx_done_tick=1;
					end
				else 
					s_next=s_reg+1;
	endcase
	end
assign dout=b_reg;
endmodule 
		 			
				

					