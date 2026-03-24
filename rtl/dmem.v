module dmem (
    input clk,
    input we,
    input [31:0] addr,
    input [31:0] wdata,
    output [31:0] rdata
);
    reg [31:0] mem [0:255];

    always @(posedge clk)
        if (we) mem[addr[9:2]] <= wdata;

    assign rdata = mem[addr[9:2]];
endmodule