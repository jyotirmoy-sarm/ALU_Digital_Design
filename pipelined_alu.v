`timescale 1ns / 1ps

module pipelined_alu #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,        // Active-high synchronous reset
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    input  wire [2:0]       ALU_Sel,
    output reg  [WIDTH-1:0] ALU_Out,
    output reg              CarryOut,
    output reg              Overflow,
    output reg              Zero,
    output reg              Negative
);

    // STAGE 1: Combinational Logic Evaluation
    wire [WIDTH:0]   stage1_add_sub;    // Extra (WIDTH) holds Carry/Borrow
    wire [WIDTH-1:0] stage1_and;
    wire [WIDTH-1:0] stage1_or;
    wire [WIDTH-1:0] stage1_xor;
    wire [WIDTH-1:0] stage1_nor;
    wire [WIDTH-1:0] stage1_asr;
    wire [WIDTH-1:0] stage1_lsl;
    wire             stage1_overflow;

    // 1. Arithmetic Execution (ADD / SUB)
    assign stage1_add_sub = (ALU_Sel == 3'b001) ? (A - B) : (A + B);

    // 2. Signed Overflow Calculation
    assign stage1_overflow = (ALU_Sel == 3'b000) ? ((A[WIDTH-1] == B[WIDTH-1]) && (stage1_add_sub[WIDTH-1] != A[WIDTH-1])) :
                             (ALU_Sel == 3'b001) ? ((A[WIDTH-1] != B[WIDTH-1]) && (stage1_add_sub[WIDTH-1] != A[WIDTH-1])) : 1'b0;

    // 3. Bitwise Execution
    assign stage1_and = A & B;
    assign stage1_or  = A | B;
    assign stage1_xor = A ^ B;
    assign stage1_nor = ~(A | B);

    // 4. Shift Execution
    assign stage1_asr = $signed(A) >>> B;
    assign stage1_lsl = A << B;


    // PIPELINE BOUNDARY: Stage 1 -> Stage 2 Intermediate Registers
    reg [WIDTH-1:0] reg_add_sub;
    reg [WIDTH-1:0] reg_and;
    reg [WIDTH-1:0] reg_or;
    reg [WIDTH-1:0] reg_xor;
    reg [WIDTH-1:0] reg_nor;
    reg [WIDTH-1:0] reg_asr;
    reg [WIDTH-1:0] reg_lsl;
    
    reg             reg_carry;
    reg             reg_overflow;
    reg [2:0]       reg_alu_sel;        // Pipelined Control Bus

    always @(posedge clk) begin
        if (rst) begin
            reg_add_sub  <= {WIDTH{1'b0}};
            reg_and      <= {WIDTH{1'b0}};
            reg_or       <= {WIDTH{1'b0}};
            reg_xor      <= {WIDTH{1'b0}};
            reg_nor      <= {WIDTH{1'b0}};
            reg_asr      <= {WIDTH{1'b0}};
            reg_lsl      <= {WIDTH{1'b0}};
            reg_carry    <= 1'b0;
            reg_overflow <= 1'b0;
            reg_alu_sel  <= 3'b000;
        end else begin
            // Lock Stage 1 computed values into intermediate registers
            reg_add_sub  <= stage1_add_sub[WIDTH-1:0];
            reg_carry    <= stage1_add_sub[WIDTH];
            reg_overflow <= stage1_overflow;
            
            reg_and      <= stage1_and;
            reg_or       <= stage1_or;
            reg_xor      <= stage1_xor;
            reg_nor      <= stage1_nor;
            reg_asr      <= stage1_asr;
            reg_lsl      <= stage1_lsl;
            
            reg_alu_sel  <= ALU_Sel;    // Forward control select signal to Stage 2
        end
    end


    // STAGE 2: Multiplexing & Synchronous Output/Flag Generation
    always @(posedge clk) begin
        if (rst) begin
            ALU_Out  <= {WIDTH{1'b0}};
            CarryOut <= 1'b0;
            Overflow <= 1'b0;
            Zero     <= 1'b0;
            Negative <= 1'b0;
        end else begin
            // Multiplex output based on registered control signal
            case (reg_alu_sel)
                3'b000:  ALU_Out <= reg_add_sub; // ADD
                3'b001:  ALU_Out <= reg_add_sub; // SUB
                3'b010:  ALU_Out <= reg_and;     // AND
                3'b011:  ALU_Out <= reg_or;      // OR
                3'b100:  ALU_Out <= reg_xor;     // XOR
                3'b101:  ALU_Out <= reg_nor;     // NOR
                3'b110:  ALU_Out <= reg_asr;     // ASR
                3'b111:  ALU_Out <= reg_lsl;     // LSL
                default: ALU_Out <= {WIDTH{1'b0}};
            endcase

            // Register sideband flags
            CarryOut <= (reg_alu_sel == 3'b000 || reg_alu_sel == 3'b001) ? reg_carry : 1'b0;
            Overflow <= (reg_alu_sel == 3'b000 || reg_alu_sel == 3'b001) ? reg_overflow : 1'b0;

            // Flags computed on selected Stage 2 result
            case (reg_alu_sel)
                3'b000, 3'b001: begin
                    Zero     <= (reg_add_sub == {WIDTH{1'b0}});
                    Negative <= reg_add_sub[WIDTH-1];
                end
                3'b010: begin
                    Zero     <= (reg_and == {WIDTH{1'b0}});
                    Negative <= reg_and[WIDTH-1];
                end
                3'b011: begin
                    Zero     <= (reg_or == {WIDTH{1'b0}});
                    Negative <= reg_or[WIDTH-1];
                end
                default: begin
                    Zero     <= (ALU_Out == {WIDTH{1'b0}});
                    Negative <= ALU_Out[WIDTH-1];
                end
            endcase
        end
    end

endmodule
