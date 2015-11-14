module top;

    reg  [2:0] dut_3_2_in;
    wire [1:0] dut_3_2_out;
    reg  [6:0] dut_7_3_in;
    wire [2:0] dut_7_3_out;

    integer test_val;

    counter_3_2 dut_3_2(dut_3_2_in, dut_3_2_out);
    counter_7_3 dut_7_3(dut_7_3_in, dut_7_3_out);

    reg passed;

    initial 
    begin
        passed = 1'b1;

        $display("Testing 3:2");
        for(dut_3_2_in = 3'b000; dut_3_2_in != 3'b111; dut_3_2_in = dut_3_2_in + 3'b001) begin
            #10 test_val = dut_3_2_in[0] + dut_3_2_in[1] + dut_3_2_in[2];
            if(dut_3_2_out != test_val) begin
                $display("3:2 incorrect at %b (actual: %b, expected: %b)", dut_3_2_in, dut_7_3_out, test_val[1:0]);
                passed = 1'b0;
            end
        end

        if(passed == 1'b1) begin
            #10 $display("Test passed.");
        end else begin
            #10 $display("Test failed.");
        end

        passed = 1'b1;

        $display("Testing 7:3");
        for(dut_7_3_in = 7'b0000000; dut_7_3_in != 7'b1111111; dut_7_3_in = dut_7_3_in + 7'b0000001) begin
            #10 test_val = dut_7_3_in[0] + dut_7_3_in[1] + dut_7_3_in[2] + dut_7_3_in[3] + dut_7_3_in[4] + dut_7_3_in[5] + dut_7_3_in[6];
            if(dut_7_3_out != test_val) begin
                $display("7:3 incorrect at %b (actual: %b, expected: %b)", dut_7_3_in, dut_7_3_out, test_val[2:0]);
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
