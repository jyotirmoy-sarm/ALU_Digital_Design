`timescale 1ns / 1ps

module parametric_alu_tb;

    
    parameter WIDTH = 8;

    // Inputs
    reg  [WIDTH-1:0] A;
    reg  [WIDTH-1:0] B;
    reg  [2:0]       ALU_Sel;

    // Outputs
    wire [WIDTH-1:0] ALU_Out;
    wire             CarryOut;
    wire             Overflow;
    wire             Zero;
    wire             Negative;

    parametric_alu #(
        .WIDTH(WIDTH)
    ) uut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .ALU_Out(ALU_Out),
        .CarryOut(CarryOut),
        .Overflow(Overflow),
        .Zero(Zero),
        .Negative(Negative)
    );

    initial begin
        
        $display(" PARAMETRIC ALU FULL VERIFICATION");
        

         // Test 1: Addition (ALU_Sel = 0) [0 ns - 10 ns]
        A = 8'd15; B = 8'd10; ALU_Sel = 3'b000; #10;
        if (ALU_Out === 8'd25 && CarryOut === 0 && Overflow === 0)
            $display("[PASS] Test 1: Addition (15 + 10 = 25)");
        else
            $display("[FAIL] Test 1: Addition Result = %d", ALU_Out);

        
        // Test 2: Signed Overflow Addition (ALU_Sel = 0) [10 ns - 20 ns]
       
        A = 8'd120; B = 8'd10; ALU_Sel = 3'b000; #10;
        if (Overflow === 1'b1)
            $display("[PASS] Test 2: Signed Overflow Flag Assertion");
        else
            $display("[FAIL] Test 2: Overflow Flag not asserted!");

        
        // Test 3: Standard Subtraction (ALU_Sel = 1) [20 ns - 30 ns]
        
        A = 8'd50; B = 8'd20; ALU_Sel = 3'b001; #10;
        if (ALU_Out === 8'd30 && CarryOut === 0)
            $display("[PASS] Test 3: Subtraction (50 - 20 = 30)");
        else
            $display("[FAIL] Test 3: Subtraction Result = %d", ALU_Out);

        // Test 4: Subtraction Borrow & Negative (ALU_Sel = 1) [30 ns - 40 ns]
        A = 8'd10; B = 8'd15; ALU_Sel = 3'b001; #10;
        if (Negative === 1'b1 && CarryOut === 1'b1)
            $display("[PASS] Test 4: Negative & Borrow CarryOut Assertion");
        else
            $display("[FAIL] Test 4: Negative/Borrow Flags incorrect!");

        
        // Test 5: Bitwise AND & Zero Flag (ALU_Sel = 2) [40 ns - 50 ns]
        
        A = 8'b10101010; B = 8'b01010101; ALU_Sel = 3'b010; #10;
        if (ALU_Out === 8'b00000000 && Zero === 1'b1)
            $display("[PASS] Test 5: Bitwise AND & Zero Flag");
        else
            $display("[FAIL] Test 5: Zero Flag check failed!");

        // Test 6: Bitwise OR Masking (ALU_Sel = 3) [50 ns - 60 ns]
        A = 8'b10100000; B = 8'b00001010; ALU_Sel = 3'b011; #10;
        if (ALU_Out === 8'b10101010)
            $display("[PASS] Test 6: Bitwise OR");
        else
            $display("[FAIL] Test 6: Bitwise OR check failed!");

        // Test 7: Bitwise XOR (ALU_Sel = 4) [60 ns - 70 ns]
        A = 8'b11001100; B = 8'b10101010; ALU_Sel = 3'b100; #10;
        if (ALU_Out === 8'b01100110)
            $display("[PASS] Test 7: Bitwise XOR");
        else
            $display("[FAIL] Test 7: Bitwise XOR check failed!");

        // Test 8: Bitwise NOR (ALU_Sel = 5) [70 ns - 80 ns]
        A = 8'b11000000; B = 8'b00001100; ALU_Sel = 3'b101; #10;
        if (ALU_Out === 8'b00110011)
            $display("[PASS] Test 8: Bitwise NOR");
        else
            $display("[FAIL] Test 8: Bitwise NOR check failed!");

        // Test 9: Arithmetic Shift Right (ALU_Sel = 6) [80 ns - 90 ns]
        A = 8'b11110000; B = 8'd2; ALU_Sel = 3'b110; #10;
        if (ALU_Out === 8'b11111100) // Preserves sign bit '1'
            $display("[PASS] Test 9: Arithmetic Shift Right (Sign-Preserved)");
        else
            $display("[FAIL] Test 9: Arithmetic Shift Right check failed!");

        // Test 10: Logical Shift Left (ALU_Sel = 7) [90 ns - 100 ns]
        A = 8'b00000011; B = 8'd2; ALU_Sel = 3'b111; #10;
        if (ALU_Out === 8'b00001100)
            $display("[PASS] Test 10: Logical Shift Left");
        else
            $display("[FAIL] Test 10: Shift Left check failed!");

        $display("  VERIFICATION COMPLETE - ALL LOGS PROCESSED");
 
         $finish;
    end

endmodule