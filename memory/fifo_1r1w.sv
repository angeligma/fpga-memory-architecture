module fifo_1r1w
  #(parameter [31:0] width_p = 8
   // Note: Not depth_p! depth_p should be 1<<depth_log2_p
   ,parameter [31:0] depth_log2_p = 8
   )
  (input [0:0] clk_i
  ,input [0:0] reset_i

  ,input [width_p - 1:0] data_i
  ,input [0:0] valid_i
  ,output [0:0] ready_o 

  ,output [0:0] valid_o 
  ,output [width_p - 1:0] data_o 
  ,input [0:0] ready_i
  );
  logic [depth_log2_p:0] rd_ptr_q, wr_ptr_q;
  logic [width_p-1:0]    rd_data_q, last_data_q;
  logic [depth_log2_p:0] rd_addr_next_q;

  logic first_write_q, tail_q, wr_en_q, rd_en_q, full_q, empty_q;

  assign wr_en_q = valid_i & ready_o;
  assign rd_en_q = valid_o & ready_i;

  assign rd_addr_next_q = rd_en_q ? (rd_ptr_q + 1) : rd_ptr_q;

  assign full_q =(wr_ptr_q[depth_log2_p] ^ rd_ptr_q[depth_log2_p]) && (wr_ptr_q[depth_log2_p-1:0] == rd_ptr_q[depth_log2_p-1:0]);

  assign empty_q = ~(wr_ptr_q[depth_log2_p] ^ rd_ptr_q[depth_log2_p]) && (wr_ptr_q[depth_log2_p-1:0] == rd_ptr_q[depth_log2_p-1:0]);

  assign ready_o = ~full_q;
  assign valid_o = ~empty_q;

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      wr_ptr_q <= '0;
      rd_ptr_q <= '0;
    end else begin
      if (wr_en_q) wr_ptr_q <= wr_ptr_q + 1;
      if (rd_en_q) rd_ptr_q <= rd_ptr_q + 1;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      last_data_q <= '0;
    end else begin
      if (wr_en_q) last_data_q <= data_i;
    end
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      tail_q        <= '0;
      first_write_q <= '0;
    end else begin
      tail_q        <= rd_en_q & (rd_addr_next_q == wr_ptr_q);
      first_write_q <= (first_write_q & rd_en_q) | (wr_en_q & empty_q);
    end
  end


  ram_1r1w_sync #(
    .width_p   (width_p),
    .depth_p   (1 << depth_log2_p),
    .filename_p("")
  ) fifo_mem (
    .clk_i      (clk_i),
    .reset_i    (reset_i),
    .wr_valid_i (wr_en_q),
    .wr_data_i  (data_i),
    .wr_addr_i  (wr_ptr_q[depth_log2_p-1:0]),
    .rd_valid_i (1'b1),
    .rd_addr_i  (rd_addr_next_q[depth_log2_p-1:0]),
    .rd_data_o  (rd_data_q)
  );

  assign data_o = (first_write_q | tail_q) ? last_data_q : rd_data_q;
endmodule
