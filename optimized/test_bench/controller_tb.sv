module controller_tb;

  parameter WORD_SIZE = 32;
  parameter L1_DELAY = 3;
  parameter L2_DELAY = 3;

  logic clk;
  logic rst;
  logic wr_en;
  logic read_en;
  logic [WORD_SIZE-1:0] addr;
  logic [WORD_SIZE-1:0] data;
  logic [WORD_SIZE-1:0] data_out;

  controller #(
      .WORD_SIZE(WORD_SIZE),
      .L1_DELAY (L1_DELAY),
      .L2_DELAY (L2_DELAY)
  ) dut (
      .clk(clk),
      .rst(rst),
      .wr_en(wr_en),
      .read_en(read_en),
      .addr(addr),
      .data(data),
      .data_out(data_out)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Initial block
  initial begin
    $dumpvars(0, controller_tb);
    $dumpfile("controller_tb.vcd");
    $display("Starting Controller Testbench");
    clk = 1;
    rst = 1;
    wr_en = 0;
    read_en = 0;
    addr = 0;
    data = 0;

    #10 rst = 0;

    // -------------------------------------------------------
    // TEST 1: Write to address 0x10
    // -------------------------------------------------------
    $display("[TEST 1] Write to address 0x10");
    wr_en = 1;
    addr  = 32'h00000010;
    data  = 32'hA5A5A5A5;
    #60;
    wr_en = 0;
    repeat (L1_DELAY + L2_DELAY + 1) @(posedge clk);

    // -------------------------------------------------------
    // TEST 2: Read from different address 0x11 (simulate miss)
    // -------------------------------------------------------
    $display("[TEST 2] Read from address 0x11 (no write done)");
    wr_en = 0;
    read_en = 1;
    addr = 32'h00000011;
    #60;
    repeat (L1_DELAY + L2_DELAY + 1) @(posedge clk);
    $display("Read Data from 0x11: %h", data_out);

    // -------------------------------------------------------
    // TEST 3: Write to address 0x20
    // -------------------------------------------------------
    $display("[TEST 3] Write to address 0x20");
    wr_en = 1;
    read_en = 0;
    addr = 32'h00000020;
    data = 32'h5A5A5A5A;
    #60;
    wr_en = 0;
    repeat (L1_DELAY + L2_DELAY + 1) @(posedge clk);

    // -------------------------------------------------------
    // TEST 4: Read from different address 0x21 (simulate miss)
    // -------------------------------------------------------
    $display("[TEST 4] Read from address 0x21 (no write done)");
    wr_en = 0;
    read_en = 1;
    addr = 32'h00000010;
    #60;
    repeat (L1_DELAY + L2_DELAY + 1) @(posedge clk);
    $display("Read Data from 0x21: %h", data_out);

    // -------------------------------------------------------
    // TEST 5: Write to address 0x30 then read from 0x31
    // -------------------------------------------------------
    $display("[TEST 5] Write to address 0x30 then Read from address 0x31");
    wr_en = 1;
    read_en = 0;
    addr = 32'h00000030;
    data = 32'h12345678;
    #60;
    wr_en = 0;
    repeat (L1_DELAY + L2_DELAY + 1) @(posedge clk);

    addr = 32'h00000020;  // different read address
    wr_en = 0;
    read_en = 1;
    #60;
    repeat (L1_DELAY + L2_DELAY + 1) @(posedge clk);
    $display("Read Data from 0x31: %h", data_out);

    // -------------------------------------------------------
    $display("Controller Testbench Completed");
    $finish;
  end

endmodule
