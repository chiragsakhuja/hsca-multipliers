module top;

    reg  [3:0] dut4x4_a;
    reg  [3:0] dut4x4_b;
    wire [7:0] dut4x4_out;

    integer test_val;

    dadda32x32_3_2 dut4x4(dut4x4_a, dut4x4_b, dut4x4_out);

    reg passed;
    integer i, j;

    initial 
    begin
        passed = 1'b1;

        $display("Testing 4x4 Mult");
        for(i = 4'h0; i <= 4'hf; i = i + 1) begin
            for(j = 4'h0; j <= 4'hf; j = j + 1) begin
                dut4x4_a = i[3:0];
                dut4x4_b = j[3:0];
                #10 test_val = i * j;
                if(dut4x4_out != test_val[7:0]) begin
                    $display("Error: %d * %d != %d (expected %d)", dut4x4_a, dut4x4_b, dut4x4_out, test_val[7:0]);
                    passed = 1'b0;
                end
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
