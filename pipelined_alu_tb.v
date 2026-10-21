`timescale 1ns / 1ps

module pipelined_alu_tb;

    parameter WIDTH = 8;

    reg             clk;
    reg             rst;
    reg [WIDTH-1:0] A;
    reg [WIDTH-1:0] B;
    reg [2:0]       ALU_Sel;

    wire [WIDTH-1:0] ALU_Out;
    wire             CarryOut;
    wire             Overflow;
    wire             Zero;
    wire             Negative;

   
    pipelined_alu #(.WIDTH(WIDTH)) uut (
        .clk(clk), .rst(rst),
        .A(A), .B(B), .ALU_Sel(ALU_Sel),
        .ALU_Out(ALU_Out), .CarryOut(CarryOut),
        .Overflow(Overflow), .Zero(Zero), .Negative(Negative)
    );

    // Clock Generator: 10 ns period (100 MHz clock)
    always #5 clk = ~clk;

    initial begin
        // Initialize Signals
        clk = 0; rst = 1; A = 0; B = 0; ALU_Sel = 0;
        
        // Hold Reset for 2 Clock Cycles
        repeat (2) @(posedge clk);
        rst = 0;
        
        $display(" PIPELINED ALU VERIFICATION ");

        // Cycle 1 Input Drive: Addition (15 + 10)
        @(posedge clk);
        A = 8'd15; B = 8'd10; ALU_Sel = 3'b000;

        // Cycle 2 Input Drive: Subtraction (50 - 20)
        // At this edge, Stage 1 takes (50 - 20), while Stage 2 outputs (15 + 10 = 25)
        @(posedge clk);
        A = 8'd50; B = 8'd20; ALU_Sel = 3'b001;

        // Check Cycle 1 Output (15 + 10 = 25)
        if (ALU_Out === 8'd25)
            $display("[PASS] Cycle 1 Output (Addition): 15 + 10 = %d", ALU_Out);
        else
            $display("[FAIL] Cycle 1 Output Expected 25, got %d", ALU_Out);

        // Cycle 3 Input Drive: Bitwise AND
        @(posedge clk);
        A = 8'b10101010; B = 8'b01010101; ALU_Sel = 3'b010;

        // Check Cycle 2 Output (50 - 20 = 30)
        if (ALU_Out === 8'd30)
            $display("[PASS] Cycle 2 Output (Subtraction): 50 - 20 = %d", ALU_Out);
        else
            $display("[FAIL] Cycle 2 Output Expected 30, got %d", ALU_Out);

        // Clear pipeline
        repeat (2) @(posedge clk);

        $display("  PIPELINED VERIFICATION COMPLETE                 ");
        $finish;
    end

endmodule