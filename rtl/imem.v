module imem (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:255];

    `ifdef SIMULATION
        initial $readmemh("program.hex", mem);
    `else
        initial begin
            mem[0] = 32'h00500093;
            mem[1] = 32'h00A00113;
            mem[2] = 32'h002081B3;
            mem[3] = 32'h04D00513;
            mem[4] = 32'h00100593;
            mem[5] = 32'h00000593;
            mem[6] = 32'h05200513;
            mem[7] = 32'h00100593;
            mem[8] = 32'h00000593;
            mem[9] = 32'h04900513;
            mem[10] = 32'h00100593;
            mem[11] = 32'h00000593;
            mem[12] = 32'h04400513;
            mem[13] = 32'h00100593;
            mem[14] = 32'h00000593;
            mem[15] = 32'h05500513;
            mem[16] = 32'h00100593;
            mem[17] = 32'h00000593;
            mem[18] = 32'h04C00513;
            mem[19] = 32'h00100593;
            mem[20] = 32'h00000593;
            mem[21] = 32'h00000013;
        end
    `endif

    assign instr = mem[addr[9:2]];

endmodule