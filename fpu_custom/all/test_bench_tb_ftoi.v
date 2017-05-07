module test_bench_tb_ftoi;
  reg  clk;
  reg  rst;
  
  initial
  begin
    rst <= 1'b1;
    #50 rst <= 1'b0;
  end

  
  initial
  begin
    #500000 $finish;
  end

  
  initial
  begin
    clk <= 1'b0;
    while (1) begin
      #5 clk <= ~clk;
    end
  end

  test_bench_ftoi uut(
    .clk(clk),
    .rst(rst));
endmodule
