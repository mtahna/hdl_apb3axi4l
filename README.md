```wavedrom
{ 
  config: { hscale: 0 },
  head:{
    text: "WRITE",
    tick:0,
  },
  signal: [
    { name: "clk"       , wave: "p........" },
    { name: "psel"      , wave: "01.....0." },
    { name: "pwrite"    , wave: "x1.....x." },
    { name: "penable"   , wave: "0.1....0." },
    { name: "paddr"     , wave: "x3.....x.", data: ["ADDR"] },
    { name: "pwdata"    , wave: "x3.....x.", data: ["DATA"] },
    { name: "pready"    , wave: "1.0...1..", },
    { name: "pslverr"   , wave: "0........", },
    {},
    { name: "awaddr"    , wave: "x.3x.....", data: ["ADDR"] },
    { name: "awvalid"   , wave: "0.10....." },
    { name: "awready"   , wave: "1..0..1.." },
    { name: "wdata"     , wave: "x.3.x....", data: ["DATA"] },
    { name: "wvalid"    , wave: "0..10...." },
    { name: "wready"    , wave: "1...0.1.." },
    { name: "bready"    , wave: "1........" },
    { name: "bvalid"    , wave: "0....10.." },
    { name: "bresp"     , wave: "x....3x..", data: ["RESP"] },
    {},
  ],
}
```

```wavedrom
{ 
  config: { hscale: 0 },
  head:{
    text: "READ",
    tick:0,
  },
  signal: [
    { name: "clk"       , wave: "p........" },
    { name: "psel"      , wave: "01.....0." },
    { name: "pwrite"    , wave: "x0.....x." },
    { name: "penable"   , wave: "0.1....0." },
    { name: "paddr"     , wave: "x3.....x.", data: ["ADDR"] },
    { name: "prdata"    , wave: "x.....3x.", data: ["DATA"] },
    { name: "pready"    , wave: "1.0...1..", },
    { name: "pslverr"   , wave: "0........", },
    {},
    { name: "araddr"    , wave: "x.3x.....", data: ["ADDR"] },
    { name: "arvalid"   , wave: "0.10....." },
    { name: "arready"   , wave: "1..0..1.." },
    { name: "rready"    , wave: "1........" },
    { name: "rvalid"    , wave: "0....10.." },
    { name: "rdata"     , wave: "x....3x..", data: ["DATA"] },
    { name: "rresp"     , wave: "x....3x..", data: ["RESP"] },
    {},
  ],
}
```
