`timescale 1ns/1ps

module and2(input a, input b, output y);
    assign y = a & b;
endmodule

module and3(input a, input b, input c, output y);
    assign y = a & b & c;
endmodule

module and4(input a, input b, input c, input d, output y);
    assign y = a & b & c & d;
endmodule

module and5(input a, input b, input c, input d, input e, output y);
    assign y = a & b & c & d & e;
endmodule

module and6(input a, input b, input c, input d, input e, input f, output y);
    assign y = a & b & c & d & e & f;
endmodule

module or2(input a, input b, output y);
    assign y = a | b;
endmodule

module or3(input a, input b, input c, output y);
    assign y = a | b | c;
endmodule

module or4(input a, input b, input c, input d, output y);
    assign y = a | b | c | d;
endmodule

module or5(input a, input b, input c, input d, input e, output y);
    assign y = a | b | c | d | e;
endmodule

module or6(input a, input b, input c, input d, input e, input f, output y);
    assign y = a | b | c | d | e | f;
endmodule

module xor2(input a, input b, output y);
    assign y = a ^ b;
endmodule

module carry_lookahead_adder_5bit_modular(
    input  [4:0] A,
    input  [4:0] B,
    input  Cin,
    output [4:0] Sum,
    output Cout
);

    wire [4:0] G, P;
    wire C1, C2, C3, C4;

    and2 g0(A[0], B[0], G[0]);
    and2 g1(A[1], B[1], G[1]);
    and2 g2(A[2], B[2], G[2]);
    and2 g3(A[3], B[3], G[3]);
    and2 g4(A[4], B[4], G[4]);

    xor2 p0(A[0], B[0], P[0]);
    xor2 p1(A[1], B[1], P[1]);
    xor2 p2(A[2], B[2], P[2]);
    xor2 p3(A[3], B[3], P[3]);
    xor2 p4(A[4], B[4], P[4]);

    wire term_c1, term1_c2, term2_c2;
    wire term1_c3, term2_c3, term3_c3;
    wire term1_c4, term2_c4, term3_c4, term4_c4;
    wire term1_cout, term2_cout, term3_cout, term4_cout, term5_cout;

    and2 and_c1(P[0], Cin, term_c1);
    or2  or_c1(G[0], term_c1, C1);

    and2 and1_c2(P[1], G[0], term1_c2);
    and3 and2_c2(P[1], P[0], Cin, term2_c2);
    or3  or_c2(G[1], term1_c2, term2_c2, C2);

    and2 and1_c3(P[2], G[1], term1_c3);
    and3 and2_c3(P[2], P[1], G[0], term2_c3);
    and4 and3_c3(P[2], P[1], P[0], Cin, term3_c3);
    or4  or_c3(G[2], term1_c3, term2_c3, term3_c3, C3);

    and2 and1_c4(P[3], G[2], term1_c4);
    and3 and2_c4(P[3], P[2], G[1], term2_c4);
    and4 and3_c4(P[3], P[2], P[1], G[0], term3_c4);
    and5 and4_c4(P[3], P[2], P[1], P[0], Cin, term4_c4);
    or5  or_c4(G[3], term1_c4, term2_c4, term3_c4, term4_c4, C4);

    and2 and1_cout(P[4], G[3], term1_cout);
    and3 and2_cout(P[4], P[3], G[2], term2_cout);
    and4 and3_cout(P[4], P[3], P[2], G[1], term3_cout);
    and5 and4_cout(P[4], P[3], P[2], P[1], G[0], term4_cout);
    and6 and5_cout(P[4], P[3], P[2], P[1], P[0], Cin, term5_cout);
    or6  or_cout(G[4], term1_cout, term2_cout, term3_cout, term4_cout, term5_cout, Cout);

    xor2 sum0(P[0], Cin, Sum[0]);
    xor2 sum1(P[1], C1,  Sum[1]);
    xor2 sum2(P[2], C2,  Sum[2]);
    xor2 sum3(P[3], C3,  Sum[3]);
    xor2 sum4(P[4], C4,  Sum[4]);

endmodule

module tb_carry_lookahead_adder_5bit_modular;

    reg  [4:0] A;
    reg  [4:0] B;
    reg  Cin;
    wire [4:0] Sum;
    wire Cout;

    carry_lookahead_adder_5bit_modular uut(
        .A(A), .B(B), .Cin(Cin),
        .Sum(Sum), .Cout(Cout)
    );

    reg clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveforms.vcd");
        $dumpvars(0, tb_carry_lookahead_adder_5bit_modular);
    end

    initial begin
        $display(" time | Cin |   A   |   B   |  Sum  | Cout");
        $monitor("%5t |  %b  | %02d  | %02d  |  %02d   |  %b",
                  $time, Cin, A, B, Sum, Cout);
    end

    initial begin
        Cin = 0;
        A = 5'b00000; B = 5'b00001; repeat(4) @(posedge clk);
        A = 5'b00010; B = 5'b00011; repeat(4) @(posedge clk);
        A = 5'b00100; B = 5'b00101; repeat(4) @(posedge clk);
        A = 5'b01000; B = 5'b01001; repeat(4) @(posedge clk);
        A = 5'b10000; B = 5'b10001; repeat(4) @(posedge clk);

        Cin = 1;
        A = 5'b10101; B = 5'b01110; repeat(4) @(posedge clk);

        Cin = 0;
        A = 5'b11100; B = 5'b00011; repeat(4) @(posedge clk);

        Cin = 1;
        A = 5'b00111; B = 5'b11000; repeat(4) @(posedge clk);

        $finish;
    end

endmodule
