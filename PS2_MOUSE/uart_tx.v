module uart_tx #(parameter dbits=8,sb_ticks=16)(clk,reset,s_tick,tx_start,tx_done,din,tx);
input clk,reset,s_tick,tx_start;
input [7:0] din;
output reg tx_done;
output wire tx;
reg [1:0] state_reg,state_next;
reg [7:0] b_reg,b_next;
reg  [3:0]n_reg,n_next;
reg [3:0]s_reg,s_next;
reg tx_reg,tx_next;
localparam [1:0]
idle=2'b00, 
start=2'b01,
data=2'b10,
stop=2'b11;

always @(posedge clk or posedge reset)


	if(reset)
	begin
		s_reg=0;
		n_reg=0;
		b_reg=0;
		tx_reg=1;
		state_reg=idle;
	end
	else 
		
	begin
		state_reg=state_next;
		b_reg=b_next;
		n_reg=n_next;
		s_reg=s_next;
		tx_reg=tx_next;
	end
//next state logic
always @ * 
begin		
	state_next=state_reg;
	b_next=b_reg;	
	n_next=n_reg;
	s_next=s_reg;
	tx_next=tx_reg;	
	tx_done=0;
	case(state_reg)
		idle:	
		begin
			tx_next=1;
			if(tx_start)		
			begin
				state_next=start;
				s_next=0;
				b_next=din;
			end
		end
		start:
		begin
			if(s_tick)
				if(s_reg==15)
				begin
					s_next=0;
					n_next=0;
					state_next=data;
				end
				else 
					s_next=s_reg+1;
		end
		data:
		begin
			tx_next=b_reg[0];
			if(s_tick)
				if(s_reg==15)
				begin
					s_next=0;
					b_next=b_reg>>1;
				
					if(n_reg==(dbits-1))
						state_next=stop;
					else
						n_next=n_reg+1;
				end
				else
					s_next=s_reg+1;
		end
		stop:
		begin
			tx_next=1;	
			if(s_tick)
				if(s_reg==(sb_ticks-1))
				begin
					state_next=idle;
					tx_done=1;
				end
				else 
					s_next=s_reg+1;
		end
endcase
end
assign tx=tx_reg;
endmodule 
			
