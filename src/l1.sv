module l1 #(
    parameter LINE_SIZE  = 16,
    parameter INDEX_SIZE = 4,
    parameter TAG_SIZE   = 2,
    parameter WORD_SIZE  = 32
) (
    input clk,
    input wr_en,
    input [WORD_SIZE - 1:0] addr,
    input [WORD_SIZE - 1:0] data,
    output [WORD_SIZE - 1:0] data_out,
    output hit_or_miss
);

  logic [TAG_SIZE + WORD_SIZE:0] l1_cache[LINE_SIZE];
  logic [INDEX_SIZE - 1:0] index;
  logic [TAG_SIZE - 1:0] tag;

  logic cycle = 0;
  logic hm = 0;
  logic [WORD_SIZE - 1:0] dout;

  always_ff @(posedge clk) begin
    // cycle 1, assign tag, index
    if (cycle == 0) begin
      tag   <= addr[WORD_SIZE-1:WORD_SIZE-TAG_SIZE];
      index <= addr[WORD_SIZE-TAG_SIZE-1:WORD_SIZE-TAG_SIZE-INDEX_SIZE];
      cycle <= 1;
    end

    // cycle 2, check hit or miss
    else begin
      if (wr_en) begin
        hm <= 1;
        l1_cache[index] <= {1'b1, tag, data};
        dout <= data;
      end else begin
        // check if the cache line is valid
        if (l1_cache[index][TAG_SIZE+WORD_SIZE] == 0) begin
          hm <= 0;
        end
        // check if the tag matches
        else if (l1_cache[index][TAG_SIZE+WORD_SIZE] == 1 && 
                 l1_cache[index][TAG_SIZE+WORD_SIZE-1:WORD_SIZE] == tag)
        begin
          hm <= 1;
        end 
        // check if the tag does not match
        else hm <= 0;
      end
    end
  end

  assign hit_or_miss = hm;
  assign data_out = dout;

endmodule
