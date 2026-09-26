module carry_lookahead_adder_5bit_gates(
input [4:0] A,
input [4:0] B,
input Cin,
output [4:0] Sum,
output Cout
);

wire [4:0] G, P;
wire C1, C2, C3, C4;

and g0_gen(G[0], A[0], B[0]);
and g1_gen(G[1], A[1], B[1]);
and g2_gen(G[2], A[2], B[2]);
and g3_gen(G[3], A[3], B[3]);
and g4_gen(G[4], A[4], B[4]);

xor p0_gen(P[0], A[0], B[0]);
xor p1_gen(P[1], A[1], B[1]);
xor p2_gen(P[2], A[2], B[2]);
xor p3_gen(P[3], A[3], B[3]);
xor p4_gen(P[4], A[4], B[4]);

wire term1_c1, term1_c2, term2_c2, term1_c3, term2_c3, term3_c3;
wire term1_c4, term2_c4, term3_c4, term4_c4;
wire term1_cout, term2_cout, term3_cout, term4_cout, term5_cout;

and and_c1(term1_c1, P[0], Cin);
or or_c1(C1, G[0], term1_c1);

and and1_c2(term1_c2, P[1], G[0]);
and and2_c2(term2_c2, P[1], P[0], Cin);
or or_c2(C2, G[1], term1_c2, term2_c2);

and and1_c3(term1_c3, P[2], G[1]);
and and2_c3(term2_c3, P[2], P[1], G[0]);
and and3_c3(term3_c3, P[2], P[1], P[0], Cin);
or or_c3(C3, G[2], term1_c3, term2_c3, term3_c3);

and and1_c4(term1_c4, P[3], G[2]);
and and2_c4(term2_c4, P[3], P[2], G[1]);
and and3_c4(term3_c4, P[3], P[2], P[1], G[0]);
and and4_c4(term4_c4, P[3], P[2], P[1], P[0], Cin);
or or_c4(C4, G[3], term1_c4, term2_c4, term3_c4, term4_c4);

and and1_cout(term1_cout, P[4], G[3]);
and and2_cout(term2_cout, P[4], P[3], G[2]);
and and3_cout(term3_cout, P[4], P[3], P[2], G[1]);
and and4_cout(term4_cout, P[4], P[3], P[2], P[1], G[0]);
and and5_cout(term5_cout, P[4], P[3], P[2], P[1], P[0], Cin);
or or_cout(Cout, G[4], term1_cout, term2_cout, term3_cout, term4_cout, term5_cout);

xor sum0_calc(Sum[0], P[0], Cin);
xor sum1_calc(Sum[1], P[1], C1);
xor sum2_calc(Sum[2], P[2], C2);
xor sum3_calc(Sum[3], P[3], C3);
xor sum4_calc(Sum[4], P[4], C4);

endmodule