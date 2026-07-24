`ifndef BINPATH
 `define BINPATH ""
`endif
module ram_1r1w_sync
  #(parameter [31:0] width_p = 8
  ,parameter [31:0] depth_p = 512
  ,parameter string filename_p = "memory_init_file.bin")
  (input logic [0:0] clk_i
  ,input logic [0:0] reset_i

  ,input logic [0:0] wr_valid_i
  ,input logic [width_p-1:0] wr_data_i
  ,input logic [$clog2(depth_p) - 1 : 0] wr_addr_i

  ,input logic [0:0] rd_valid_i
  ,input logic [$clog2(depth_p) - 1 : 0] rd_addr_i
  ,output logic [width_p-1:0] rd_data_o);


   logic [width_p-1:0] mem [depth_p-1:0];

   always_ff @(posedge clk_i) begin
      if (reset_i) begin
         rd_data_o <= '0;
      end else begin
         if (wr_valid_i && rd_valid_i && (wr_addr_i == rd_addr_i)) begin
            rd_data_o <= mem[rd_addr_i];
            mem[wr_addr_i] <= wr_data_i;
         end else begin
            if (rd_valid_i) begin
               rd_data_o <= mem[rd_addr_i];
            end
            if (wr_valid_i) begin
               mem[wr_addr_i] <= wr_data_i;
            end
         end
      end
   end

   initial begin
      // Display depth and width (You will need to match these in your init file)
      $display("%m: depth_p is %d, width_p is %d", depth_p, width_p);
      // wire [bar:0] foo [baz:0];
      // In order to get the memory contents in iverilog you need to run this for loop during initialization:
      for (int i = 0; i < depth_p; i++) begin
         $dumpvars(0, mem[i]);
      end
   end

endmodule
