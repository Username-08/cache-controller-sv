module mem #(
    parameter MEM_SIZE  = 1024,
    parameter WORD_SIZE = 32
) (
    input clk,
    input rst,
    input wr_en,
    input [WORD_SIZE - 1:0] addr,
    input [31:0] data,
    output [31:0] data_out
);

  logic [31:0] memory[MEM_SIZE];

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      for (int i = 0; i < MEM_SIZE; i++) begin
        memory[i] <= 32'b0;
      end
    end else begin
      if (wr_en) begin
        memory[addr] <= data;
      end
    end
  end

  assign data_out = memory[addr];

endmodule

