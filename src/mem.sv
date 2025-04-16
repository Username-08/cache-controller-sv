module mem #(
    parameter MEM_SIZE = 1024
) (
    input wr_en,
    input [9:0] addr,
    input [31:0] data,
    output [31:0] data_out
);

  logic [31:0] memory[MEM_SIZE];

  always_comb begin
    if (wr_en) begin
      memory[addr] = data;
    end else begin
      memory[addr] = 0;
    end
  end

  assign data_out = memory[addr];

endmodule

