module delaybuffer
  #(parameter [31:0] width_p = 8
   ,parameter [31:0] delay_p = 8
   )
  (input [0:0] clk_i
  ,input [0:0] reset_i

  ,input logic [width_p - 1:0] data_i
  ,input logic [0:0] valid_i
  ,output logic [0:0] ready_o 

  ,output logic [0:0] valid_o 
  ,output logic [width_p - 1:0] data_o 
  ,input logic [0:0] ready_i
  );

  // Internal buffer - exactly delay_p entries
  logic [width_p-1:0] buffer [delay_p:0];
  
  assign ready_o = ready_i | ~valid_o;

  // Sequential logic - shift on every cycle when ready_i is high
  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      valid_o <= 1'b0;
      for (int i = 0; i < delay_p; i++) begin
        buffer[i] <= '0;
      end
    end 
    else if (ready_o) begin
      valid_o <= valid_i;
      if (valid_i) begin
       buffer[0] <= data_i;
        for (int i = 0; i < delay_p; i++) begin
          buffer[i+1] <= buffer[i];
        end
      end
    end
  end
  assign data_o = buffer[delay_p]; 

endmodule
