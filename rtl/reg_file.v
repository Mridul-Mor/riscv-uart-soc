module reg_file (
    input         clk,
    input  [4:0]  rs1, rs2,
    input  [4:0]  rd,
    input  [31:0] wd,
    input         we,
    output [31:0] rd1, rd2,
    output [31:0] x10_out,
    output [31:0] x11_out
);

reg [31:0] regs [31:0];

integer i;
initial begin
    for (i = 0; i < 32; i = i + 1)
        regs[i] = 32'd0;
end

always @(posedge clk) begin
    if (we && rd != 5'd0)
        regs[rd] <= wd;
end

assign rd1     = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
assign rd2     = (rs2 == 5'd0) ? 32'd0 : regs[rs2];
assign x10_out = regs[10];
assign x11_out = regs[11];

endmodule