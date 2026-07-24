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

   assign ready_o = ready_i | ~valid_o;
   logic wr_en;
   assign wr_en = ready_o && valid_i;

   always_ff @(posedge clk_i) begin
      if (reset_i)
        valid_o <= 1'b0;
      else if (ready_o)
        valid_o <= valid_i;
   end
   
  wire [3:0] tap = delay_p[3:0];
  wire [width_p-1:0] q_o;

   genvar i;
   generate
    for (i = 0; i < width_p; i++) begin : gen
      SRL16E #(.INIT(16'h0000), .IS_CLK_INVERTED(1'b0)) u_srl16e (
            .Q   (q_o[i]),
            .A0  (tap[0]),
            .A1  (tap[1]),
            .A2  (tap[2]),
            .A3  (tap[3]),
            .CE  (wr_en),
            .CLK (clk_i),
            .D   (data_i[i])
          );
    end
   endgenerate

    assign data_o = q_o;
endmodule
