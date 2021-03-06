module ha(a, b, s, c);
    input  wire a;
    input  wire b;
    output wire s;
    output wire c;

    wire a_or_b;
    wire a_and_b;
    wire a_and_b_n;

    OR2X4 gate0(a, b, a_or_b);
    AND2X4 gate1(a, b, a_and_b);
    INVX4 gate2(a_and_b, a_and_b_n);
    AND2X4 gate3(a_or_b, a_and_b_n, s);
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
    OR2X4 gate0(a_plus_b_c, out[1], a_plus_b_plus_c_c);

endmodule

module counter7(in, out);
    input  wire [6:0] in;
    output wire [2:0] out;

    wire [1:0] fa1_out;
    wire [1:0] fa2_out;
    wire [1:0] rca1_out;

    counter3 fa1(in[2:0], fa1_out);
    counter3 fa2(in[5:3], fa2_out);

    counter3 rca1({in[6]      , fa1_out[0], fa2_out[0]}, rca1_out);
    counter3 rca2({rca1_out[1], fa1_out[1], fa2_out[1]}, out[2:1]);

    assign out[0] = rca1_out[0];

endmodule

module counter15(in, out);

    input wire  [14:0] in;
    output wire [3:0] out;

    wire [2:0] c1_out;
    wire [2:0] c2_out;
    wire [1:0] rca1_out;
    wire [1:0] rca2_out;

    counter7 c1(in[6:0] , c1_out);
    counter7 c2(in[13:7], c2_out);

    counter3 rca1({in[14]     , c1_out[0], c2_out[0]}, rca1_out);
    counter3 rca2({rca1_out[1], c1_out[1], c2_out[1]}, rca2_out);
    counter3 rca3({rca2_out[1], c1_out[2], c2_out[2]}, out[3:2]);

    assign out[0] = rca1_out[0];
    assign out[1] = rca2_out[0];

endmodule
