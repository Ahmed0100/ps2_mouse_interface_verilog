module uart #(parameter dbits=8,sb_ticks=16,dvsr=163,dvsr_bits=8)
(clk,reset,rd_uart,rx_empty,wr_uart,tx_full,rd_data,wr_data,tx,rx);
input clk,reset;
input rd_uart,wr_uart,rx;


input [7:0] wr_data;
output wire [7:0] rd_data; 
output wire rx_empty,tx_full,tx;
wire tick,rx_done_tick;
wire [7:0] rx_data_out;
wire tx_fifo_not_empty,tx_done; 
wire [7:0] tx_fifo_data_out;
wire tx_empty;
modulo_counter #(.m(dvsr),.n(dvsr_bits)) ticks_generator(.clk(clk),.reset(reset),.tick(tick),.q());

uart_receiver #(.dbits(dbits),.sb_ticks(sb_ticks)) receiver(.clk(clk), .reset(reset),.rx(rx),.s_ticks(tick),
.rx_done_tick(rx_done_tick),.dout(rx_data_out));


fifo rx_fifo(.clk(clk),.reset(reset),.write(rx_done_tick),.read(rd_uart),.data_in(rx_data_out),.data_out(rd_data)
,.empty(rx_empty),.full());

uart_tx #(.dbits(dbits),.sb_ticks(sb_ticks)) transmitter (.clk(clk),.reset(reset),.s_tick(tick),.tx_start(tx_fifo_not_empty)
,.tx_done(tx_done),.din(tx_fifo_data_out),.tx(tx));
fifo tx_fifo (.clk(clk),.reset(reset),.write(wr_uart),.read(tx_done),.data_in(wr_data),.data_out(tx_fifo_data_out)
,.empty(tx_empty),.full(tx_full));
assign tx_fifo_not_empty=!tx_empty;
endmodule 
