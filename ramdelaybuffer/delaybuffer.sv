module delaybuffer
  #(parameter [31:0] width_p = 8,
    parameter [31:0] delay_p = 8)
  (input  logic                   clk_i,
   input  logic                   reset_i,

   input  logic [width_p-1:0]     data_i,
   input  logic                   valid_i,
   output logic                   ready_o,

   output logic                   valid_o,
   output logic [width_p-1:0]     data_o,
   input  logic                   ready_i);

   assign ready_o = ready_i | ~valid_o;

   localparam int clog = $clog2(delay_p + 2);
   localparam [clog-1:0] delay_const = delay_p[clog-1:0];

   logic wr_en, rd_en;
   assign wr_en = ready_o && valid_i;
   assign rd_en = ready_i && valid_o;

   logic [clog-1:0] wr_cnt_r, rd_cnt_r;

   // valid_o tracking
   always_ff @(posedge clk_i) begin
      if (reset_i)
         valid_o <= '0;
      else if (wr_en)
         valid_o <= 1'b1;
      else if (ready_o && ~valid_i)
         valid_o <= 1'b0;
   end

   // write pointer (counter)
   always_ff @(posedge clk_i) begin
      if (reset_i)
         wr_cnt_r <= delay_const;
      else if (wr_en)
         wr_cnt_r <= wr_cnt_r + 1'b1;
   end

   // read pointer (counter)
   always_ff @(posedge clk_i) begin
      if (reset_i)
         rd_cnt_r <= '0;
      else if (rd_en)
         rd_cnt_r <= rd_cnt_r + 1'b1;
   end

   // memory read address
   logic [clog-1:0] rd_addr;
   assign rd_addr = (ready_i && valid_o) ? (rd_cnt_r + 1'b1) : rd_cnt_r;

   logic [width_p-1:0] data_l;

   ram_1r1w_sync #(
      .width_p(width_p),
      .depth_p(1 << clog),
      .filename_p("")
   ) shadow_mem (
      .clk_i(clk_i),
      .reset_i(reset_i),
      .wr_valid_i(wr_en),
      .wr_data_i(data_i),
      .wr_addr_i(wr_cnt_r),
      .rd_valid_i(1'b1),
      .rd_addr_i(rd_addr),
      .rd_data_o(data_l)
   );

   assign data_o = data_l;

endmodule
