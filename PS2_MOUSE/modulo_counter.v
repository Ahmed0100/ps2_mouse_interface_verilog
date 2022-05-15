module modulo_counter #( parameter n=4,m=10)(clk,reset,tick,q);
input clk,reset;
output wire [n-1:0] q;
output wire tick;
reg [n-1:0] q_reg;
wire [n-1:0] q_next;
always @(posedge clk or posedge reset)
begin
	if(reset)
		q_reg<=0;
	else
		q_reg<=q_next;
end

assign q_next=(q_reg==(m-1))? 0: q_reg+1;
assign tick=(q_reg==(m-1))? 1:0;
assign q=q_reg;
endmodule
	
