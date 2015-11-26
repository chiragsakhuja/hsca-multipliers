module top;

    reg  [3:0] cla4x4_a;
    reg  [3:0] cla4x4_b;
    wire [4:0] cla4x4_out;

    cla4x4 dut4x4(cla4x4_a, cla4x4_b, 1'b0, cla4x4_out);

    reg  [15:0] cla16x16_a;
    reg  [15:0] cla16x16_b;
    wire [16:0] cla16x16_out;

    cla16x16 dut16x16(cla16x16_a, cla16x16_b, 1'b0, cla16x16_out);

    integer test_val;

    reg passed;
    integer i, j;

    initial
    begin
        passed = 1'b1;

        $display("Testing 4x4 CLA");
        for(i = 4'h0; i <= 4'hf; i = i + 1) begin
            for(j = 4'h0; j <= 4'hf; j = j + 1) begin
                cla4x4_a = i[3:0];
                cla4x4_b = j[3:0];
                #10 test_val = i + j;
                if(cla4x4_out != test_val[4:0]) begin
                    $display("Error: %d + %d != %d (expected %d)", cla4x4_a, cla4x4_b, cla4x4_out, test_val[4:0]);
                    passed = 1'b0;
                end
            end
        end

        if(passed == 1'b1) begin
            #10 $display("Test passed.");
        end else begin
            #10 $display("Test failed.");
        end

        passed = 1'b1;

        $display("Testing 16x16 CLA");

        for(i = 16'h0000; i <= 16'h000f; i = i + 1) begin
            cla16x16_a = i[15:0];
            cla16x16_b = i[15:0];
            #10 test_val = cla16x16_a  + cla16x16_b;
            if(cla16x16_out != test_val[16:0]) begin
                $display("Error: %b + %b != %b (expected %b)", cla16x16_a, cla16x16_b, cla16x16_out, test_val[16:0]);
                passed = 1'b0;
            end
        end

        for(i = 0; i < 10000; i = i + 1) begin
            cla16x16_a = $urandom_range(16'hffff, 16'h0000);
            cla16x16_b = $urandom_range(16'hffff, 16'h0000);
            #10 test_val = cla16x16_a  + cla16x16_b;
            if(cla16x16_out != test_val[16:0]) begin
                $display("Error: %b + %b != %b (expected %b)", cla16x16_a, cla16x16_b, cla16x16_out, test_val[16:0]);
                passed = 1'b0;
            end
        end

        for(i = 16'hfff0; i <= 16'hffff; i = i + 1) begin
            cla16x16_a = i[15:0];
            cla16x16_b = i[15:0];
            #10 test_val = cla16x16_a  + cla16x16_b;
            if(cla16x16_out != test_val[16:0]) begin
                $display("Error: %b + %b != %b (expected %b)", cla16x16_a, cla16x16_b, cla16x16_out, test_val[16:0]);
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
