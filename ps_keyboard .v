module ps_keyboard(clk,reset,rx_en,ps_c,ps_d,rx_done_tick,dout);
input clk,reset,rx_en;
input ps_c,ps_d;
output wire [7:0] dout;
localparam [1:0] 
idle=2'b00,
dps=2'b01,
load=2'b10; 

reg [1:0] state_reg,state_next;
reg [7:0] filter_reg;
wire [7:0] filter_next; 
reg psc_reg;
wire psc_next;
reg [10:0] b_reg,b_next;
reg [3:0] n_reg,n_next;
output reg rx_done_tick;
wire fallen_edge;

//neg edge detection and filteration 
always @(posedge clk or posedge reset)
	if(reset)
	begin
		filter_reg=0;
		psc_reg=0;
	end
	else
	begin
		filter_reg=filter_next;
		psc_reg=psc_next;
	end

assign filter_next={ps_c,filter_reg[7:1]};
assign psc_next=(filter_reg==8'b11111111)? 1'b1:(filter_reg==8'b00000000)? 1'b0: psc_reg;
assign fallen_edge=psc_reg && !psc_next;
//
always @(posedge clk or posedge reset)
	if(reset)
	begin
		state_reg=idle;
		b_reg=0;
		n_reg=0;
		
	end
	else 
	begin
		state_reg=state_next;
		b_reg=b_next; 
		n_reg=n_next;
	end
always @*
begin
	rx_done_tick=0;
	state_next=state_reg;
	b_next=b_reg;
	n_next=n_reg;
	case(state_reg)
		idle: 
			if(fallen_edge && rx_en)
			begin
				b_next={ps_d,b_reg[10:1]};
				n_next=4'b1001;
				state_next=dps;
			end	
		dps:
			if(fallen_edge)
				begin
				b_next={ps_d,b_reg[10:1]};
				if(n_reg==0)
				state_next=load;
				else 
				n_next=n_reg-1;
				end
		load:
			begin
			rx_done_tick=1;
			state_next=idle;
			end
	endcase
end
assign dout=b_reg[8:1];
endmodule 

				