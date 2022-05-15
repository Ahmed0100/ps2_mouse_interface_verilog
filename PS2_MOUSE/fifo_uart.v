module fifo(clk,reset,write,read,data_in,data_out,empty,full);
  input clk,reset,read,write;
  input [7:0] data_in;
  output reg[7:0] data_out;
  output wire empty,full;
  reg [7:0] ram [0:25];
  reg full_temp,empty_temp;
  reg [4:0] read_ptr,write_ptr;

  
  assign empty=empty_temp;
  assign full=full_temp;
  always @(negedge reset)
    begin 
      data_out<=8'b0;
      full_temp<=0;
      empty_temp<=1;
      read_ptr<=0;
      write_ptr<=0;
    end
    always @(posedge clk)
      begin
        if((full_temp==0) && (write==1))
          begin
	#10
            ram[write_ptr]=data_in;
            empty_temp<=0;
            write_ptr=write_ptr+1;
            if(write_ptr==read_ptr)
              full_temp<=1;
          end
        if((read==1)&&(empty_temp==0))
          begin
            data_out=ram[read_ptr];
            read_ptr=read_ptr+1;
            full_temp<=0;
            if(read_ptr==write_ptr)
              empty_temp<=1;
          end
      end
endmodule

