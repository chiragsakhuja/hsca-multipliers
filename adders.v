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

module carry(c_in, p, g, c_out);

    input wire c_in;
    input wire p;
    input wire g;

    output wire c_out;

    wire p_and_c_in;

    and(p_and_c_in, c_in, p);
    or(c_out, g, p_and_c_in);

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
    and(gp, p[3], p[2], p[1], p[0]);

    // compute group generate
    wire gg_term[2:0];

    and(gg_term[0], g[0], p[3], p[2], p[1]);                // g_0 p_3 p_2 p_1
    and(gg_term[1], g[1], p[3], p[2]);                      // g_1 p_3 p_2
    and(gg_term[2], g[2], p[3]);                            // g_2 p_3
    or(gg, g[3], gg_term[2], gg_term[1], gg_term[0]);       // g_3 + g_2 p_3 + g_1 p_3 p_2 + g_0 p_3 p_2 p_1

endmodule

module cla4x4_pg(a, b, c, s, fp, fg);

    input  wire [3:0] a;
    input  wire [3:0] b;
    input  wire c;

    output wire [3:0] s;
    output wire fp;
    output wire fg;

    wire [3:0] p;
    wire [3:0] g;
    wire [3:1] cg;

    // connect adders and CLA logic
    cla4x4_add adders(a, b, c, cg, s, p, g);
    cla4x4_gen cla_log(p, g, c, cg, fp, fg);

endmodule

module cla4x4(a, b, c, s);

    input  wire [3:0] a;
    input  wire [3:0] b;
    input  wire c;

    output wire [4:0] s;

    wire fp;
    wire fg;

    // connect adders and CLA logic
    cla4x4_pg adder(a, b, c, s[3:0], fp, fg);
    
    // compute carry
    carry c_out(c, fp, fg, s[4]);

endmodule

module cla16x16_pg(a, b, c, s, fp, fg);

    input  wire [15:0] a;
    input  wire [15:0] b;
    input  wire c;

    output wire [15:0] s;
    output wire fp;
    output wire fg;

    // first level wires
    wire [3:0] gp;
    wire [3:0] gg;

    // second level wires
    wire [3:1] cg;

    // generate first level of adders and CLA logic
    cla4x4_pg adder0(a[3:0]  , b[3:0]  , c    , s[3:0]  , gp[0], gg[0]);
    cla4x4_pg adder1(a[7:4]  , b[7:4]  , cg[1], s[7:4]  , gp[1], gg[1]);
    cla4x4_pg adder2(a[11:8] , b[11:8] , cg[2], s[11:8] , gp[2], gg[2]);
    cla4x4_pg adder3(a[15:12], b[15:12], cg[3], s[15:12], gp[3], gg[3]);

    //generate
    //   genvar i; 
    //   for(i = 1; i < 4; i = i + 1) begin : gen
    //       //if(i == 0) begin
    //       //    cla4x4_add adders(a[3+4*i:4*i], b[3+4*i:4*i], c, cg1[i], s[3+4*i:4*i], p1[i], g1[i]);
    //       //    cla4x4_gen cla_log1(p1[i], g1[i], c, cg1[i], gp1[i], gg1[i]);
    //       //end else begin
    //           cla4x4_add adders(a[3+4*i:4*i], b[3+4*i:4*i], cg2[i], cg1[i], s[3+4*i:4*i], p1[i], g1[i]);
    //           cla4x4_gen cla_log1(p1[i], g1[i], cg2[i], cg1[i], gp1[i], gg1[i]);
    //       //end
    //   end
    //endgenerate

    // create second level of CLA logic
    cla4x4_gen cla_log_2(gp, gg, c, cg, fp, fg);

endmodule

module cla16x16(a, b, c, s);
    input  wire [15:0] a;
    input  wire [15:0] b;
    input  wire c;

    output wire [16:0] s;

    wire fp;
    wire fg;

    cla16x16_pg adder(a, b, c, s[15:0], fp, fg);
    carry c_out(c, fp, fg, s[16]);
endmodule

//module adder14x14(a, b, out);
//
//    input  wire [13:0] a;
//    input  wire [13:0] b;
//    output wire [14:0] out;
//
//endmodule
