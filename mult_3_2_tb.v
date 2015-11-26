module top;

    reg  [7:0]  mult8x8_a;
    reg  [7:0]  mult8x8_b;
    wire [15:0] mult8x8_out;

    reg  [15:0] mult16x16_a;
    reg  [15:0] mult16x16_b;
    wire [31:0] mult16x16_out;

    reg  [31:0] mult32x32_a;
    reg  [31:0] mult32x32_b;
    wire [63:0] mult32x32_out;

    reg  [63:0]  mult64x64_a;
    reg  [63:0]  mult64x64_b;
    wire [127:0] mult64x64_out;

    reg [127:0] test_val;

    dadda8x8_3_2   dut8x8  (mult8x8_a  , mult8x8_b  , mult8x8_out);
    dadda16x16_3_2 dut16x16(mult16x16_a, mult16x16_b, mult16x16_out);
    dadda32x32_3_2 dut32x32(mult32x32_a, mult32x32_b, mult32x32_out);
    dadda64x64_3_2 dut64x64(mult64x64_a, mult64x64_b, mult64x64_out);

    reg passed;
    integer i;

    initial
    begin
        passed = 1'b1;
        $display("Testing 8x8 mult with 3:2 counters");

        for(i = 0; i < 1000; i = i + 1) begin
            mult8x8_a = $urandom_range(8'hff, 8'h00);
            mult8x8_b = $urandom_range(8'hff, 8'h00);
            #10 test_val = mult8x8_a * mult8x8_b;
            if(mult8x8_out != test_val[15:0]) begin
                $display("Error: %b + %b != %b (expected %b)", mult8x8_a, mult8x8_b, mult8x8_out, test_val[15:0]);
                passed = 1'b0;
            end
        end

        if(passed == 1'b1) begin
            #10 $display("Test passed.");
        end else begin
            #10 $display("Test failed.");
        end

        passed = 1'b1;
        $display("Testing 16x16 mult with 3:2 counters");

        for(i = 0; i < 1000; i = i + 1) begin
            mult16x16_a = $urandom_range(16'hffff, 16'h0000);
            mult16x16_b = $urandom_range(16'hffff, 16'h0000);
            #10 test_val = mult16x16_a * mult16x16_b;
            if(mult16x16_out != test_val[31:0]) begin
                $display("Error: %b + %b != %b (expected %b)", mult16x16_a, mult16x16_b, mult16x16_out, test_val[31:0]);
                passed = 1'b0;
            end
        end

        if(passed == 1'b1) begin
            #10 $display("Test passed.");
        end else begin
            #10 $display("Test failed.");
        end

        passed = 1'b1;
        $display("Testing 32x32 mult with 3:2 counters");

        for(i = 0; i < 1000; i = i + 1) begin
            mult32x32_a = $urandom_range(32'hffffffff, 32'h00000000);
            mult32x32_b = $urandom_range(32'hffffffff, 32'h00000000);
            #10 test_val = mult32x32_a * mult32x32_b;
            if(mult32x32_out != test_val[63:0]) begin
                $display("Error: %b + %b != %b (expected %b)", mult32x32_a, mult32x32_b, mult32x32_out, test_val[63:0]);
                passed = 1'b0;
            end
        end

        if(passed == 1'b1) begin
            #10 $display("Test passed.");
        end else begin
            #10 $display("Test failed.");
        end

        passed = 1'b1;
        $display("Testing 64x64 mult with 3:2 counters");

        for(i = 0; i < 1000; i = i + 1) begin
            mult64x64_a = $urandom_range(64'hffffffffffffffff, 64'h0000000000000000);
            mult64x64_b = $urandom_range(64'hffffffffffffffff, 64'h0000000000000000);
            #10 test_val = mult64x64_a * mult64x64_b;
            if(mult64x64_out != test_val[127:0]) begin
                $display("Error: %b + %b != %b (expected %b)", mult64x64_a, mult64x64_b, mult64x64_out, test_val[127:0]);
                passed = 1'b0;
            end
        end

        if(passed == 1'b1) begin
            #10 $display("Test passed.");
        end else begin
            #10 $display("Test failed.");
        end

        $finish();
    end

endmodule
