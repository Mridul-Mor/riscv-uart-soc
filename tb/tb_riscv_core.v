`timescale 1ns/1ps

module tb_riscv_core;

reg clk, rst_n;
wire tx;

reg rx;

soc_top dut (
    .clk  (clk),
    .rst_n(rst_n),
    .rx   (rx),
    .tx   (tx)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("sim/dump.vcd");
    $dumpvars(0, tb_riscv_core);
end

initial begin
    clk = 0;
    rst_n = 0;
    rx= 1;
    #20;
    rst_n = 1;
    #800000;       
    $finish;
end


always @(posedge clk) begin
    if (rst_n && dut.core.uart_start)
        $display("uart_data=%0d (%c)", 
                  dut.core.uart_data,
                  dut.core.uart_data);
end

endmodule