module riscv_core (
    input         clk,
    input         rst_n,
    // UART interface (baad mein SoC ke liye)
    output [7:0]  uart_data,
    output        uart_start
);


wire [31:0] pc, pc_next, pc_plus4, pc_branch;
wire [31:0] instr;
wire [31:0] rd1, rd2, wd;
wire [31:0] imm;
wire [31:0] alu_in_b, alu_result;
wire [31:0] mem_rdata;
wire        zero;


wire reg_we, mem_we, mem_re;
wire alu_src, mem_to_reg;
wire branch, jal;
wire [3:0] alu_ctrl;


reg [31:0] pc_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc_reg <= 32'd0;
    else        pc_reg <= pc_next;
end
assign pc = pc_reg;


imem imem_inst (
    .addr (pc),
    .instr(instr)
);


control_unit ctrl (
    .opcode (instr[6:0]),
    .funct3 (instr[14:12]),
    .funct7 (instr[31:25]),
    .reg_we (reg_we),
    .mem_we (mem_we),
    .mem_re (mem_re),
    .alu_src (alu_src),
    .mem_to_reg(mem_to_reg),
    .branch (branch),
    .jal (jal),
    .alu_ctrl (alu_ctrl)
);


reg_file rf (
    .clk (clk),
    .rs1 (instr[19:15]),
    .rs2 (instr[24:20]),
    .rd  (instr[11:7]),
    .wd  (wd),
    .we  (reg_we),
    .rd1 (rd1),
    .rd2 (rd2),
    .x10_out(x10_out),
    .x11_out(x11_out)
);


imm_gen ig (
    .instr(instr),
    .imm  (imm)
);


assign alu_in_b = alu_src ? imm : rd2;


alu alu_inst (
    .a (rd1),
    .b (alu_in_b),
    .alu_ctrl(alu_ctrl),
    .result (alu_result),
    .zero (zero)
);


dmem dmem_inst (
    .clk (clk),
    .we (mem_we),
    .addr (alu_result),
    .wdata (rd2),
    .rdata (mem_rdata)
);


assign wd = mem_to_reg ? mem_rdata : alu_result;


assign pc_plus4 = pc + 32'd4;
assign pc_branch = pc + imm;
assign pc_next = (branch & zero) ? pc_branch :
                   jal              ? pc_branch :
                                      pc_plus4;


wire [31:0] x10_out, x11_out;
assign uart_data = x10_out[7:0];
assign uart_start = x11_out[0];
endmodule