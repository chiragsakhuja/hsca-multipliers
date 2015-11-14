module mfa(a, b, c, s, p, g);

    input  wire a;
    input  wire b;
    input  wire c;

    output wire s;
    output wire p;
    output wire g;

    wire a_or_b;
    wire a_and_b;
    wire a_and_b_n;
    wire a_plus_b_s;
    wire a_plus_b_s_or_c;
    wire a_plus_b_s_and_c;
    wire a_plus_b_s_and_c_n;

    // first level half adder
    or(a_or_b, a, b);
    and(a_and_b, a, b);
    not(a_and_b_n, a_and_b);
    and(a_plus_b_s, a_or_b, a_and_b_n);

    // second level half adder
    or(a_plus_b_s_or_c, a_plus_b_s, c);
    and(a_plus_b_s_and_c, a_plus_b_s, c);
    not(a_plus_b_s_and_c_n, a_plus_b_s_and_c);
    and(s, a_plus_b_s_or_c, a_plus_b_s_and_c_n);

    // propagate and carry
    assign p = a_or_b;
    assign g = a_and_b;

endmodule

module cla4x4_add(a, b, c, cg, s, p, g);

    input  wire [3:0] a;
    input  wire [3:0] b;
    input  wire c;
    input  wire [3:1] cg;

    output wire [3:0] s;
    output wire [3:0] p;
    output wire [3:0] g;

    mfa b0(a[0], b[0], c    , s[0], p[0], g[0]);
    mfa b1(a[1], b[1], cg[1], s[1], p[1], g[1]);
    mfa b2(a[2], b[2], cg[2], s[2], p[2], g[2]);
    mfa b3(a[3], b[3], cg[3], s[3], p[3], g[3]);

endmodule

module cla4x4_gen(p, g, c, cg, gp, gg);

    input   wire [3:0] p;
    input   wire [3:0] g;
    input   wire c;

    output wire [3:1] cg;
    output wire gp;
    output wire gg;

    // compute carry for mfa[1]
    wire cg1_term;

    and(cg1_term, c, p[0]);                                 // c_0 p_0
    or(cg[1], g[0], cg1_term);                              // g_0 + c_0 p_0

    // compute carry for mfa[2]
    wire cg2_term[1:0];

    and(cg2_term[0], c   , p[1], p[0]);                     // c_0 p_1 p_0
    and(cg2_term[1], g[0], p[1]);                           // g_0 p_1
    or(cg[2], g[1], cg2_term[1], cg2_term[0]);              // g_1 + g_0 p_1 + c_0 p_1 p_0

    // compute carry for mfa[3]
    wire cg3_term[2:0];

    and(cg3_term[0], c   , p[2], p[1], p[0]);               // c_0 p_2 p_1 p_0
    and(cg3_term[1], g[0], p[2], p[1]);                     // g_0 p_2 p_1
    and(cg3_term[2], g[1], p[2]);                           // g_1 p_2
    or(cg[3], g[2], cg3_term[2], cg3_term[1], cg3_term[0]); // g_2 + g_1 p_2 + g_0 p_2 p_1 + c_0 p_2 p_1 p_0
    
    // compute group propagate
    or(gp, p[3], p[2], p[1], p[0]);

    // compute group generate
    wire gg_term[2:0];

    and(gg_term[0], g[0], p[3], p[2], p[1]);                // g_0 p_3 p_2 p_1
    and(gg_term[1], g[1], p[3], p[2]);                      // g_1 p_3 p_2
    and(gg_term[2], g[2], p[3]);                            // g_2 p_3
    or(gg, g[3], gg_term[2], gg_term[1], gg_term[0]);       // g_3 + g_2 p_3 + g_1 p_3 p_2 + g_0 p_3 p_2 p_1

endmodule

module cla4x4(a, b, c, s);

    input  wire [3:0] a;
    input  wire [3:0] b;
    input  wire c;

    output wire [4:0] s;

    wire [3:0] p;
    wire [3:0] g;
    wire [3:1] cg;


    wire gp;
    wire gp_and_c;
    wire gg;

    cla4x4_add adders(a, b, c, cg, s[3:0], p, g);
    cla4x4_gen cla_log(p, g, c, cg, gp, gg);
    
    // compute carry
    and(gp_and_c, gp, c);
    or(s[4], gp_and_c, gg);

endmodule

//module adder14x14(a, b, out);
//
//    input  wire [13:0] a;
//    input  wire [13:0] b;
//    output wire [14:0] out;
//
//endmodule
