module AND2X4(a, b, c);
    input a;
    input b;
    output c;

    assign c = a & b;
endmodule

module OR2X4(a, b, c);
    input a;
    input b;
    output c;

    assign c = a | b;
endmodule

module INVX4(a, b);
    input a;
    output b;

    assign b = ~a;
endmodule
