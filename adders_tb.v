module top;

    reg  [3:0] cla4x4_a;
    reg  [3:0] cla4x4_b;
    wire [4:0] cla4x4_out;

    cla4x4 dut4x4(cla4x4_a, cla4x4_b, 1'b0, cla4x4_out);

    integer test_val;

    reg passed;
    integer i, j;

    initial 
    begin
        passed = 1'b1;

        $display("Testing CLA 4x4");
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

        $finish();
    end

endmodule
