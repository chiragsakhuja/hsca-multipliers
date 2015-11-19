module ha(a, b, s, c);
    input  wire a;
    input  wire b;
    output wire s;
    output wire c;

    wire a_or_b;
    wire a_and_b;
    wire a_and_b_n;

    or(a_or_b, a, b);
    and(a_and_b, a, b);
    not(a_and_b_n, a_and_b);
    and(s, a_or_b, a_and_b_n);
    assign c = a_and_b;

endmodule

module counter3(in, out);
    input  wire [2:0] in;
    output wire [1:0] out;

    wire a_plus_b_s;
    wire a_plus_b_c;
    wire a_plus_b_plus_c_c;

    ha one(in[0], in[1], a_plus_b_s, a_plus_b_c);
    ha two(in[2], a_plus_b_s, out[0], a_plus_b_plus_c_c);
    or(out[1], a_plus_b_plus_c_c, a_plus_b_c);

endmodule

module counter7(in, out);
    input  wire [6:0] in;
    output wire [2:0] out;

    wire [1:0] fa1_out;
    wire [1:0] fa2_out;
    wire [1:0] rca1_out;
    wire [1:0] rca2_out;

    counter3 fa1(in[2:0], fa1_out);
    counter3 fa2(in[5:3], fa2_out);
    counter3 rca1({in[6], fa1_out[0], fa2_out[0]}, rca1_out);
    counter3 rca2({rca1_out[1], fa1_out[1], fa2_out[1]}, out[2:1]);

    assign out[0] = rca1_out[0];

endmodule
