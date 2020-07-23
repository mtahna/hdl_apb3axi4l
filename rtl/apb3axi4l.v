//--------------------------------------------------------------------------------
// Module Definition
//--------------------------------------------------------------------------------
module apb3axi4l #(
  parameter ADDR_WIDTH = 12 , // max32
  parameter DATA_WIDTH = 32   // max32
)(
  input  wire                  clk        , // Common 
  input  wire                  resetn     , // Common 
  input  wire                  psel       , // APB3 Slave
  input  wire                  pwrite     , // APB3 Slave
  input  wire                  penable    , // APB3 Slave
  input  wire [ADDR_WIDTH-1:0] paddr      , // APB3 Slave
  input  wire [DATA_WIDTH-1:0] pwdata     , // APB3 Slave
  output reg  [DATA_WIDTH-1:0] prdata     , // APB3 Slave
  output reg                   pready     , // APB3 Slave
  output reg                   pslverr    , // APB3 Slave
  output reg  [ADDR_WIDTH-1:0] awaddr     , // AXI4-Lite Master
  output reg                   awvalid    , // AXI4-Lite Master
  input  wire                  awready    , // AXI4-Lite Master
  output reg  [DATA_WIDTH-1:0] wdata      , // AXI4-Lite Master
  output reg                   wvalid     , // AXI4-Lite Master
  input  wire                  wready     , // AXI4-Lite Master
  input  wire [1:0]            bresp      , // AXI4-Lite Master
  input  wire                  bvalid     , // AXI4-Lite Master
  output wire                  bready     , // AXI4-Lite Master
  output reg  [ADDR_WIDTH-1:0] araddr     , // AXI4-Lite Master
  output reg                   arvalid    , // AXI4-Lite Master
  input  wire                  arready    , // AXI4-Lite Master
  input  wire [DATA_WIDTH-1:0] rdata      , // AXI4-Lite Master
  input  wire [1:0]            rresp      , // AXI4-Lite Master
  input  wire                  rvalid     , // AXI4-Lite Master
  output wire                  rready       // AXI4-Lite Master
);

//--------------------------------------------------------------------------------
// Private Parameters
//--------------------------------------------------------------------------------
  // none

//--------------------------------------------------------------------------------
// Sequential, Combinatorial Logic
//--------------------------------------------------------------------------------
  wire s_write_req = psel & (~penable) & pwrite;
  wire s_read_req = psel & (~penable) & (~pwrite);

  // AXI Write Transfer
  wire s_awch_hs = awvalid & awready;
  always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
      awvalid <= 1'b0;
    end else begin
      if      (s_write_req) awvalid <= 1'b1;
      else if (s_awch_hs  ) awvalid <= 1'b0;
    end
  end
  always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
      awaddr <= {ADDR_WIDTH{1'b0}};
    end else begin
      if (s_write_req) awaddr <= paddr;
    end
  end
  wire s_wch_hs = wvalid & wready;
  always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
      wvalid <= 1'b0;
    end else begin
      if      (s_awch_hs) wvalid <= 1'b1;
      else if (s_wch_hs ) wvalid <= 1'b0;
    end
  end
  always @(posedge clk or negedge resetn ) begin
    if (~resetn) begin
      wdata <= {DATA_WIDTH{1'b0}};
    end else begin
      if (s_awch_hs) wdata <= pwdata;
    end
  end
  wire s_bch_hs = bvalid & bready;
  assign bready = 1'b1;

  // AXI Read Transfer
  wire s_arch_hs = arvalid & arready;
  always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
      arvalid <= 1'b0;
    end else begin
      if      (s_read_req) arvalid <= 1'b1;
      else if (s_arch_hs ) arvalid <= 1'b0;
    end
  end
  always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
      araddr <= {ADDR_WIDTH{1'b0}};
    end else begin
      if (s_read_req) araddr <= paddr;
    end
  end
  wire s_rch_hs = rvalid & rready;
  assign rready = 1'b1;

  // APB Response
  always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
      prdata <= {DATA_WIDTH{1'b0}};
    end else begin
      if (s_rch_hs) prdata <= rdata;
    end
  end

  always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
      pready <= 1'b1;
    end else begin
      if      (s_bch_hs    | s_rch_hs  ) pready <= 1'b1;
      else if (s_write_req | s_read_req) pready <= 1'b0;
    end
  end

  always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
      pslverr <= 1'b0;
    end else begin
      pslverr <= (s_bch_hs & bresp[1]) | (s_rch_hs & rresp[1]);
    end
  end


endmodule