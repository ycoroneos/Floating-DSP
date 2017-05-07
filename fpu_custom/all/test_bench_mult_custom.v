module test_bench_multiplier_custom;
  reg  clk;
  reg  rst;
  
  initial
  begin
    rst <= 1'b1;
    #50 rst <= 1'b0;
  end

  initial
  begin
    #10000 $finish;
  end

  initial
  begin
    clk <= 1'b0;
    while (1) begin
      #1 clk <= ~clk;
    end
  end

  reg [31:0] ina;
  reg [31:0] inb;

  initial
  begin
  #50
    // 2.0 in floating point
    ina = 32'b01000000000000000000000000000000;
    inb = 32'b01000000000000000000000000000000;

  forever #50 ina = ina + 1;
  // #100
  //   // 2.0 in floating point
  //   ina = 32'b01000000100000000000000000000000;
  //   inb = 32'b01000000100000000000000000000000;

  end

  reg clka;
  reg clkb;
  reg clkc;
  reg clkd;

  wire   [31:0] wire_39069600;
  wire   wire_39069600_stb;
  wire   wire_39069600_ack;
  wire   [31:0] wire_39795024;
  wire   wire_39795024_stb;
  wire   wire_39795024_ack;
  wire   [31:0] wire_39795168;
  wire   wire_39795168_stb;
  wire   wire_39795168_ack;

  // initial begin
  // clka = 0;
  // clkb = 0;
  // #50 
  // clka = 1;
  // clkb = 1;
  // #10
  // clka = 0;
  // clkb = 0;
  // #50
  // clka = 1;
  // clkb = 1;
  // #10
  // clka = 0;
  // clkb = 0;
  // end

  initial begin
  clka = 1;
  clkb = 1;
  end

  initial begin
  clkd = 0;
  #110 rst = 1;
  #10 rst = 0;
  end


  // initial begin
  // clkd = 0;

  // #82 clkd = 1;
  // #2 clkd = 0;

  // #100 clkd = 1;
  // #2 clkd = 0;
  // end

  assign wire_39069600 = ina;
  assign wire_39795024 = inb;

  assign wire_39069600_stb = clka;
  assign wire_39795024_stb = clkb;
  // assign wire_39795168_stb = clkc;

  assign wire_39795168_ack = clkd;

  // file_writer file_writer_39028208(
  //   .clk(clk),
  //   .rst(rst),
  //   .input_a(wire_39795168),
  //   .input_a_stb(wire_39795168_stb),
  //   .input_a_ack(wire_39795168_ack));
  multiplier multiplier_39759952(
    .clk(clk),
    .rst(rst),
    .input_a(wire_39069600),
    .input_a_stb(wire_39069600_stb),
    .input_a_ack(wire_39069600_ack),
    .input_b(wire_39795024),
    .input_b_stb(wire_39795024_stb),
    .input_b_ack(wire_39795024_ack),
    .output_z(wire_39795168),
    .output_z_stb(wire_39795168_stb),
    .output_z_ack(wire_39795168_ack));

  always @(posedge wire_39795168_ack)
  begin
  $display("Got value on output: %b", wire_39795168);
  end
endmodule
