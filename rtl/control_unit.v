module control_unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg  reg_we, // register write enable
    output reg  mem_we,// memory write enable
    output reg  mem_re,// memory read enable
    output reg  alu_src, // 0=rs2, 1=imm
    output reg  mem_to_reg, // 0=ALU, 1=Mem
    output reg  branch, // branch instruction?
    output reg  jal, // JAL?
    output reg [3:0] alu_ctrl // ALU operation
);

always @(*) begin
    // defaults — sab off
    {reg_we, mem_we, mem_re, alu_src, mem_to_reg, branch, jal} = 7'b0;
    alu_ctrl = 4'b0000; // ADD

    case (opcode)
        7'b0110011: begin // R-type
            reg_we   = 1;
            alu_src  = 0;
            case ({funct7[5], funct3})
                4'b0000: alu_ctrl = 4'b0000; // ADD
                4'b1000: alu_ctrl = 4'b0001; // SUB
                4'b0111: alu_ctrl = 4'b0010; // AND
                4'b0110: alu_ctrl = 4'b0011; // OR
                4'b0100: alu_ctrl = 4'b0100; // XOR
                4'b0010: alu_ctrl = 4'b0101; // SLT
                4'b0011: alu_ctrl = 4'b0110; // SLTU
                4'b0001: alu_ctrl = 4'b0111; // SLL
                4'b0101: alu_ctrl = 4'b1000; // SRL
                4'b1101: alu_ctrl = 4'b1001; // SRA
                default: alu_ctrl = 4'b0000;
            endcase
        end

        7'b0010011: begin // I-type ALU (ADDI, ANDI...)
            reg_we   = 1;
            alu_src  = 1;
            case (funct3)
                3'b000: alu_ctrl = 4'b0000; // ADDI
                3'b111: alu_ctrl = 4'b0010; // ANDI
                3'b110: alu_ctrl = 4'b0011; // ORI
                3'b100: alu_ctrl = 4'b0100; // XORI
                3'b010: alu_ctrl = 4'b0101; // SLTI
                3'b011: alu_ctrl = 4'b0110; // SLTIU
                3'b001: alu_ctrl = 4'b0111; // SLLI
                3'b101: alu_ctrl = (funct7[5]) ? 4'b1001 : 4'b1000; // SRAI/SRLI
                default: alu_ctrl = 4'b0000;
            endcase
        end

        7'b0000011: begin // Load (LW)
            reg_we   = 1;
            mem_re   = 1;
            alu_src  = 1;
            mem_to_reg = 1;
            alu_ctrl = 4'b0000; // ADD (base + offset)
        end

        7'b0100011: begin // Store (SW)
            mem_we   = 1;
            alu_src  = 1;
            alu_ctrl = 4'b0000; // ADD
        end

        7'b1100011: begin // Branch (BEQ, BNE...)
            branch   = 1;
            alu_ctrl = 4'b0001; // SUB (zero flag check)
        end

        7'b1101111: begin // JAL
            reg_we = 1;
            jal    = 1;
        end

        default: ; // NOP
    endcase
end

endmodule