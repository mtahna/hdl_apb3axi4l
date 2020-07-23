`timescale 1ns/1ps
module tb ();

localparam ADDR_WIDTH=12;
localparam DATA_WIDTH=32;

logic                  clk        ; // Common 
logic                  resetn     ; // Common 
logic                  psel       ; // APB3 Slave
logic                  pwrite     ; // APB3 Slave
logic                  penable    ; // APB3 Slave
logic [ADDR_WIDTH-1:0] paddr      ; // APB3 Slave
logic [DATA_WIDTH-1:0] pwdata     ; // APB3 Slave
logic [DATA_WIDTH-1:0] prdata     ; // APB3 Slave
logic                  pready     ; // APB3 Slave
logic                  pslverr    ; // APB3 Slave
logic [ADDR_WIDTH-1:0] awaddr     ; // AXI4-Lite Master
logic                  awvalid    ; // AXI4-Lite Master
logic                  awready    ; // AXI4-Lite Master
logic [DATA_WIDTH-1:0] wdata      ; // AXI4-Lite Master
logic                  wvalid     ; // AXI4-Lite Master
logic                  wready     ; // AXI4-Lite Master
logic [1:0]            bresp      ; // AXI4-Lite Master
logic                  bvalid     ; // AXI4-Lite Master
logic                  bready     ; // AXI4-Lite Master
logic [ADDR_WIDTH-1:0] araddr     ; // AXI4-Lite Master
logic                  arvalid    ; // AXI4-Lite Master
logic                  arready    ; // AXI4-Lite Master
logic [DATA_WIDTH-1:0] rdata      ; // AXI4-Lite Master
logic [1:0]            rresp      ; // AXI4-Lite Master
logic                  rvalid     ; // AXI4-Lite Master
logic                  rready     ; // AXI4-Lite Master

apb3axi4l #(
  .ADDR_WIDTH  (ADDR_WIDTH),
  .DATA_WIDTH  (DATA_WIDTH) 
) uapb3axi4l (
  .clk        (clk        ), // input  wire                  Common 
  .resetn     (resetn     ), // input  wire                  Common 
  .psel       (psel       ), // input  wire                  APB3 Slave
  .pwrite     (pwrite     ), // input  wire                  APB3 Slave
  .penable    (penable    ), // input  wire                  APB3 Slave
  .paddr      (paddr      ), // input  wire [ADDR_WIDTH-1:0] APB3 Slave
  .pwdata     (pwdata     ), // input  wire [DATA_WIDTH-1:0] APB3 Slave
  .prdata     (prdata     ), // output reg  [DATA_WIDTH-1:0] APB3 Slave
  .pready     (pready     ), // output reg                   APB3 Slave
  .pslverr    (pslverr    ), // output reg                   APB3 Slave
  .awaddr     (awaddr     ), // output reg  [ADDR_WIDTH-1:0] AXI4-Lite Master
  .awvalid    (awvalid    ), // output reg                   AXI4-Lite Master
  .awready    (awready    ), // input  wire                  AXI4-Lite Master
  .wdata      (wdata      ), // output reg  [DATA_WIDTH-1:0] AXI4-Lite Master
  .wvalid     (wvalid     ), // output reg                   AXI4-Lite Master
  .wready     (wready     ), // input  wire                  AXI4-Lite Master
  .bresp      (bresp      ), // input  wire [1:0]            AXI4-Lite Master
  .bvalid     (bvalid     ), // input  wire                  AXI4-Lite Master
  .bready     (bready     ), // output reg                   AXI4-Lite Master
  .araddr     (araddr     ), // output reg  [ADDR_WIDTH-1:0] AXI4-Lite Master
  .arvalid    (arvalid    ), // output reg                   AXI4-Lite Master
  .arready    (arready    ), // input  wire                  AXI4-Lite Master
  .rdata      (rdata      ), // input  wire [DATA_WIDTH-1:0] AXI4-Lite Master
  .rresp      (rresp      ), // input  wire [1:0]            AXI4-Lite Master
  .rvalid     (rvalid     ), // input  wire                  AXI4-Lite Master
  .rready     (rready     )  // output reg                   AXI4-Lite Master
);

assign awready = 1'b1;
assign wready  = 1'b1;
logic wch_hs;
always @(posedge clk) wch_hs <= wvalid & wready;
always @(posedge clk or negedge resetn) begin
  if (~resetn) begin 
    bvalid <= 1'b0;
  end else begin
    bvalid <= wch_hs;
  end
end

assign arready = 1'b1;
logic [1:0] arch_hs;
always @(posedge clk) arch_hs <= {arch_hs[0], arvalid & arready};
always @(posedge clk or negedge resetn) begin
  if (~resetn) begin 
    rvalid <= 1'b0;
  end else begin
    rvalid <= arch_hs[1];
  end
end

initial begin
    clk = 1;
    forever #1000 clk = ~clk;
end

initial begin
    resetn = 0; 
    psel = 0; pwrite = 0; penable = 0; paddr = {ADDR_WIDTH{1'b0}}; pwdata = {DATA_WIDTH{1'b0}};
    bresp = {2{1'b0}}; rresp = {2{1'b0}}; rdata = {DATA_WIDTH{1'b0}};

    repeat(10) @(posedge clk);
    resetn = 1;
    repeat(10) @(posedge clk);

    // ------------------------------------------------------
    // Normal Check
    // ------------------------------------------------------
    bresp = 2'b00; rresp = 2'b00; rdata = 32'hCCCCCCCC;

    // Write Check
    @(posedge clk); #1; psel = 1; pwrite = 1; penable = 0; paddr = 12'h100; pwdata = 32'h01234567;
    @(posedge clk); #1;                       penable = 1;
    while (pready == 0) @(posedge clk); #1;
                        psel = 0;             penable = 0;
    @(posedge clk); #1;
    @(posedge clk); #1;

    // Read Check
    @(posedge clk); #1; psel = 1; pwrite = 0; penable = 0; paddr = 12'h200;
    @(posedge clk); #1;                       penable = 1;
    while (pready == 0) @(posedge clk); #1;
                        psel = 0;             penable = 0; 
    @(posedge clk); #1;
    @(posedge clk); #1;

    // ------------------------------------------------------
    // Error Check
    // ------------------------------------------------------
    bresp = 2'b10; rresp = 2'b10; rdata = 32'hA5A5A5A5;

    // Write Check
    @(posedge clk); #1; psel = 1; pwrite = 1; penable = 0; paddr = 12'h100; pwdata = 32'h89ABCDEF;
    @(posedge clk); #1;                       penable = 1;
    while (pready == 0) @(posedge clk); #1;
                        psel = 0;             penable = 0;
    @(posedge clk); #1;
    @(posedge clk); #1;

    // Read Check
    @(posedge clk); #1; psel = 1; pwrite = 0; penable = 0; paddr = 12'h200;
    @(posedge clk); #1;                       penable = 1;
    while (pready == 0) @(posedge clk); #1;
                        psel = 0;             penable = 0; 
    @(posedge clk); #1;
    @(posedge clk); #1;

    repeat(10) @(posedge clk);
    $finish;
end

endmodule