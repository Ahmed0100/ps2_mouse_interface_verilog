module ps2_transmitter(clk,reset,wr_ps2,din,ps2_c_in,ps2_d_in,ps2_c_out,ps2_d_out,tx_idle,tx_done);
input clk,reset,wr_ps2;
input [7:0] din;
input ps2_c_in,ps2_d_in;
output reg tx_idle,tx_done;
output reg ps2_c_out,ps2_d_out;

localparam [2:0] 
idle=3'b000,
rts=3'b001,
start=3'b010,
data=3'b011,
stop=3'b100;

reg [2:0] state_reg,state_next;
reg [8:0] b_reg,b_next;
reg [3:0] n_reg,n_next;
reg [12:0] counter_reg,counter_next;
wire parity;


//negedge detection with noise cancellation 
reg [7:0] filter_reg;
wire [7:0] filter_next;
reg ps2_c_reg;
wire ps2_c_next;
wire fallen_edge;

always @(posedge clk or posedge reset)
	if(reset)
		begin
		filter_reg=0;
		ps2_c_reg=0;
		end
	else  
		begin
		filter_reg=filter_next;
		ps2_c_reg=ps2_c_next;
		end

assign filter_next={ps2_c_in,filter_reg[7:1]};
assign ps2_c_next=(filter_reg==8'b11111111) ? 1'b1 : (filter_reg==8'b00000000) ? 1'b0 : ps2_c_reg;
assign fallen_edge=(ps2_c_reg)&&(~ps2_c_next);
//

always @(posedge clk or posedge reset)
	if(reset)
		begin
		state_reg=idle;
		b_reg=0;
		n_reg=0;
		counter_reg=0;
		end
	else
		begin
		state_reg=state_next;
		b_reg=b_next;
		n_reg=n_next;
		counter_reg=counter_next;
		end
assign parity=~(^din);
always @*
	begin
	state_next=state_reg;
	b_next=b_reg;
	n_next=n_reg;
	counter_next=counter_reg;
	tx_done=0;
	tx_idle=0;
	ps2_c_out=1;
	ps2_d_out=1;
	
	case(state_reg)
		idle:
			begin
			tx_idle=1;
			if(wr_ps2)
				begin
				state_next=rts;
				b_next={parity,din};
				counter_next=13'h1fff;
				end
			end
		rts: 
			begin
				ps2_c_out=0; 
		
				if(counter_reg==0)
					state_next=start;
				else
					counter_next=counter_reg-1;
			end
		start:
			begin
			ps2_d_out=0;
	
			if(fallen_edge)
				begin
				n_next=8;
				state_next=data;
				end
			end
		data:
			begin
			ps2_d_out=b_reg[0];
		
			if(fallen_edge)
				begin
				b_next={1'b0,b_reg[8:1]};
				if(n_reg==0)
					state_next=stop;
				else
					n_next=n_reg-1;
				end
			end
		stop:	
			if(fallen_edge)
				begin
				state_next=idle;
				tx_done=1;
				end
	endcase
	end

endmodule 
			
			

				



