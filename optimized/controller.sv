module controller #(
    parameter WORD_SIZE = 32,
    parameter L1_DELAY  = 3,
    parameter L2_DELAY  = 3
) (
    input clk,
    input rst,
    input wr_en,
    input read_en,
    input [WORD_SIZE - 1:0] addr,
    input [WORD_SIZE - 1:0] data,
    output logic [WORD_SIZE - 1:0] data_out
);
  logic [WORD_SIZE - 1:0] l1_out;
  logic [WORD_SIZE - 1:0] l2_out;
  logic [WORD_SIZE - 1:0] mem_out;

  logic [L1_DELAY - 1:0] l1_counter;
  logic [L2_DELAY - 1:0] l2_counter;

  logic l1_hit;
  logic l2_hit;

  logic [WORD_SIZE - 1:0] addr_prev;

  // create fsm to control the cache and memory with states l1, l2, mem, idle
  logic [2:0] state;
  logic [2:0] next_state;

  typedef enum logic [2:0] {
    IDLE,
    L1,
    L2,
    MEM,
    WRITE
  } State;

  // create gated clocks
  logic clk_l1;
  logic clk_l2;
  logic clk_mem;

  l1 l1_cache (
      .clk(clk_l1),
      .rst(rst),
      .wr_en(wr_en),
      .addr(addr),
      .data(data),
      .data_out(l1_out),
      .hit_or_miss(l1_hit)
  );

  l2 l2_cache (
      .clk(clk_l2),
      .rst(rst),
      .wr_en(wr_en),
      .addr(addr),
      .data(data),
      .data_out(l2_out),
      .hit_or_miss(l2_hit)
  );

  mem memory (
      .clk(clk_mem),
      .rst(rst),
      .wr_en(wr_en),
      .addr(addr),
      .data(data),
      .data_out(mem_out)
  );



  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      l1_counter <= 0;
      l2_counter <= 0;
      data_out   <= 0;
      state      <= IDLE;
    end else begin
      // set new state
      state <= next_state;
      case (state)
        IDLE: begin
          l1_counter <= 0;
          l2_counter <= 0;
        end
        L1: begin
          if (l1_counter < L1_DELAY) l1_counter <= l1_counter + 1;
          if (l1_hit) data_out <= l1_out;
          l2_counter <= 0;
        end
        L2: begin
          if (l2_counter < L2_DELAY) l2_counter <= l2_counter + 1;
          if (l2_hit) data_out <= l2_out;
          l1_counter <= 0;
        end
        MEM: begin
          data_out   <= mem_out;
          l1_counter <= 0;
          l2_counter <= 0;
        end
        WRITE: begin
          if (l1_counter < L1_DELAY) l1_counter <= l1_counter + 1;
          if (l2_counter < L2_DELAY) l2_counter <= l2_counter + 1;
          data_out <= 0;
        end
        default: data_out <= 0;
      endcase
    end
  end

  always_comb begin
    case (state)
      IDLE: begin
        if (wr_en) next_state = WRITE;
        else if (read_en) begin
          next_state = L1;
        end
      end
      L1: begin
        if (l1_counter == L1_DELAY) begin
          if (l1_hit) begin
            next_state = IDLE;
          end else begin
            next_state = L2;
          end
        end
      end
      L2: begin
        if (l2_counter == L2_DELAY) begin
          if (l2_hit) begin
            next_state = IDLE;
          end else begin
            next_state = MEM;
          end
        end
      end
      MEM: begin
        next_state = IDLE;
      end
      WRITE: begin
        if (l1_counter == L1_DELAY && l2_counter == L2_DELAY) begin
          next_state = IDLE;
        end
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end
  assign clk_l1  = clk && ((state == L1) || (state == WRITE));
  assign clk_l2  = clk && ((state == L2) || (state == WRITE));
  assign clk_mem = clk && ((state == MEM) || (state == WRITE));
endmodule

