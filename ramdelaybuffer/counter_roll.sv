module counter_roll
  #(parameter [31:0] max_val_p = 15
   ,parameter width_p = $clog2(max_val_p)
    /* verilator lint_off WIDTHTRUNC */
   ,parameter [width_p-1:0] reset_val_p = '0
    )
    /* verilator lint_on WIDTHTRUNC */
   (input  [0:0]               clk_i
   ,input  [0:0]               reset_i
   ,input  [0:0]               up_i
   ,input  [0:0]               down_i
   ,output [width_p-1:0]       count_o);

   localparam [width_p-1:0] max_val_lp = max_val_p[width_p-1:0];

   logic [width_p-1:0] count_r;
   logic [width_p-1:0] next_count;

   assign count_o = count_r;

   always_comb begin
      next_count = count_r;

      unique case ({up_i, down_i})
         2'b10: begin
            if (count_r == max_val_lp)
               next_count = '0;
            else
               next_count = count_r + 1'b1;
         end
         2'b01: begin
            if (count_r == '0)
               next_count = max_val_lp;
            else
               next_count = count_r - 1'b1;
         end
         default: begin
            next_count = count_r;
         end
      endcase
   end

   always_ff @(posedge clk_i) begin
      if (reset_i) begin
         count_r <= reset_val_p;
      end else begin
         count_r <= next_count;
      end
   end

endmodule
