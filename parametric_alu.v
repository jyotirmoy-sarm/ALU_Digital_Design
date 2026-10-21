
`timescale 1ns / 1ps

module parametric_alu #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    input  wire [2:0]       ALU_Sel,
    output reg  [WIDTH-1:0] ALU_Out,
    output reg              CarryOut,
    output reg              Overflow,
    output wire             Zero,
    output wire             Negative
);

    // Continuous assignment for Combinational Status Flags
    assign Zero     = (ALU_Out == {WIDTH{1'b0}});
    assign Negative = ALU_Out[WIDTH-1];

    always @(*) begin
        // Default assignments 
        CarryOut = 1'b0;
        Overflow = 1'b0;
        
        case (ALU_Sel)
            3'b000: begin // Addition
                {CarryOut, ALU_Out} = A + B;
                Overflow = (~(A[WIDTH-1] ^ B[WIDTH-1])) && (ALU_Out[WIDTH-1] ^ A[WIDTH-1]);
            end
            
            3'b001: begin // Subtraction
                ALU_Out  = A - B;
                CarryOut = (A < B) ? 1'b1 : 1'b0; 
                Overflow = ((A[WIDTH-1] ^ B[WIDTH-1])) && (ALU_Out[WIDTH-1] ^ A[WIDTH-1]);
            end
            
            3'b010: begin // Bitwise AND
                ALU_Out = A & B;
            end
            
            3'b011: begin // Bitwise OR
                ALU_Out = A | B;
            end
            
            3'b100: begin // Bitwise XOR
                ALU_Out = A ^ B;
            end
            
            3'b101: begin // Bitwise NOR
                ALU_Out = ~(A | B);
            end
            
            3'b110: begin // Arithmetic Shift Right 
                ALU_Out = $signed(A) >>> B[2:0];
            end
            
            3'b111: begin // Logical Shift Left
                ALU_Out = A << B[2:0];
            end
            
            default: begin
                ALU_Out  = {WIDTH{1'b0}};
                CarryOut = 1'b0;
                Overflow = 1'b0;
            end
        endcase
    end

endmodule