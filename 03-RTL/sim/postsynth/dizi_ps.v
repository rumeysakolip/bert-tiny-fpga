// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Tue Oct 27 10:40:37 2026
// Host        : pc running 64-bit major release  (build 9200)
// Command     : write_verilog -mode funcsim -force sim/postsynth/dizi_ps.v
// Design      : systolic_nxn
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module pe
   (CO,
    A,
    b_in,
    a_out,
    b_out,
    c_flat,
    Q,
    acc_reg_i_18_0,
    \a_out_reg[8]_0 ,
    \a_out_reg[8]_1 ,
    last_seen,
    in_valid,
    a_col,
    b_row,
    pe_rst,
    E,
    clk,
    en);
  output [0:0]CO;
  output [8:0]A;
  output [7:0]b_in;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input [10:0]Q;
  input [10:0]acc_reg_i_18_0;
  input \a_out_reg[8]_0 ;
  input \a_out_reg[8]_1 ;
  input last_seen;
  input in_valid;
  input [8:0]a_col;
  input [7:0]b_row;
  input pe_rst;
  input [0:0]E;
  input clk;
  input en;

  wire [8:0]A;
  wire [0:0]CO;
  wire [0:0]E;
  wire [10:0]Q;
  wire [8:0]a_col;
  wire [8:0]a_out;
  wire \a_out_reg[8]_0 ;
  wire \a_out_reg[8]_1 ;
  wire [10:0]acc_reg_i_18_0;
  wire acc_reg_i_18_n_3;
  wire acc_reg_i_19_n_0;
  wire acc_reg_i_19_n_1;
  wire acc_reg_i_19_n_2;
  wire acc_reg_i_19_n_3;
  wire acc_reg_i_1__24_n_0;
  wire acc_reg_i_20_n_0;
  wire acc_reg_i_21_n_0;
  wire acc_reg_i_22_n_0;
  wire acc_reg_i_23_n_0;
  wire acc_reg_i_24_n_0;
  wire acc_reg_i_25_n_0;
  wire acc_reg_i_26_n_0;
  wire acc_reg_i_27_n_0;
  wire acc_reg_i_28_n_0;
  wire acc_reg_i_29_n_0;
  wire acc_reg_i_2__9_n_0;
  wire acc_reg_i_30_n_0;
  wire acc_reg_i_31_n_0;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [7:0]b_row;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire [8:8]\g_row[0].g_col[0].a_in ;
  wire in_valid;
  wire last_seen;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;
  wire [3:2]NLW_acc_reg_i_18_CO_UNCONNECTED;
  wire [3:0]NLW_acc_reg_i_18_O_UNCONNECTED;
  wire [3:0]NLW_acc_reg_i_19_O_UNCONNECTED;

  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \a_out[8]_i_1 
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[8]),
        .O(\g_row[0].g_col[0].a_in ));
  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(A[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(A[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(A[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(A[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(A[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(A[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(A[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(A[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(\g_row[0].g_col[0].a_in ),
        .Q(a_out[8]),
        .R(pe_rst));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-12 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_i_1__24_n_0,acc_reg_i_1__24_n_0,acc_reg_i_1__24_n_0,acc_reg_i_1__24_n_0,acc_reg_i_1__24_n_0,acc_reg_i_1__24_n_0,acc_reg_i_2__9_n_0,acc_reg_i_2__9_n_0,acc_reg_i_2__9_n_0,acc_reg_i_2__9_n_0,acc_reg_i_2__9_n_0,acc_reg_i_2__9_n_0,acc_reg_i_2__9_n_0,acc_reg_i_2__9_n_0,acc_reg_i_2__9_n_0,acc_reg_i_2__9_n_0,A[8],A[8],A[8],A[8],A[8],A}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b0),
        .CEA2(1'b0),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b0),
        .CEB2(1'b0),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(1'b0),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(1'b0),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_12
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[7]),
        .O(A[7]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_13
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[6]),
        .O(A[6]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_14
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[5]),
        .O(A[5]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_15
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[4]),
        .O(A[4]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_16
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[3]),
        .O(A[3]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_17
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[2]),
        .O(A[2]));
  (* COMPARATOR_THRESHOLD = "11" *) 
  CARRY4 acc_reg_i_18
       (.CI(acc_reg_i_19_n_0),
        .CO({NLW_acc_reg_i_18_CO_UNCONNECTED[3:2],CO,acc_reg_i_18_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,acc_reg_i_20_n_0,acc_reg_i_21_n_0}),
        .O(NLW_acc_reg_i_18_O_UNCONNECTED[3:0]),
        .S({1'b0,1'b0,acc_reg_i_22_n_0,acc_reg_i_23_n_0}));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_18__0
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[1]),
        .O(A[1]));
  (* COMPARATOR_THRESHOLD = "11" *) 
  CARRY4 acc_reg_i_19
       (.CI(1'b0),
        .CO({acc_reg_i_19_n_0,acc_reg_i_19_n_1,acc_reg_i_19_n_2,acc_reg_i_19_n_3}),
        .CYINIT(1'b0),
        .DI({acc_reg_i_24_n_0,acc_reg_i_25_n_0,acc_reg_i_26_n_0,acc_reg_i_27_n_0}),
        .O(NLW_acc_reg_i_19_O_UNCONNECTED[3:0]),
        .S({acc_reg_i_28_n_0,acc_reg_i_29_n_0,acc_reg_i_30_n_0,acc_reg_i_31_n_0}));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_19__0
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[0]),
        .O(A[0]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_1__20
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[7]),
        .O(b_in[7]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_1__24
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[8]),
        .O(acc_reg_i_1__24_n_0));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_20
       (.I0(Q[10]),
        .I1(acc_reg_i_18_0[10]),
        .O(acc_reg_i_20_n_0));
  LUT4 #(
    .INIT(16'h2F02)) 
    acc_reg_i_21
       (.I0(Q[8]),
        .I1(acc_reg_i_18_0[8]),
        .I2(acc_reg_i_18_0[9]),
        .I3(Q[9]),
        .O(acc_reg_i_21_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    acc_reg_i_22
       (.I0(acc_reg_i_18_0[10]),
        .I1(Q[10]),
        .O(acc_reg_i_22_n_0));
  LUT4 #(
    .INIT(16'h9009)) 
    acc_reg_i_23
       (.I0(Q[8]),
        .I1(acc_reg_i_18_0[8]),
        .I2(Q[9]),
        .I3(acc_reg_i_18_0[9]),
        .O(acc_reg_i_23_n_0));
  LUT4 #(
    .INIT(16'h44D4)) 
    acc_reg_i_24
       (.I0(acc_reg_i_18_0[7]),
        .I1(Q[7]),
        .I2(Q[6]),
        .I3(acc_reg_i_18_0[6]),
        .O(acc_reg_i_24_n_0));
  LUT4 #(
    .INIT(16'h44D4)) 
    acc_reg_i_25
       (.I0(acc_reg_i_18_0[5]),
        .I1(Q[5]),
        .I2(Q[4]),
        .I3(acc_reg_i_18_0[4]),
        .O(acc_reg_i_25_n_0));
  LUT4 #(
    .INIT(16'h44D4)) 
    acc_reg_i_26
       (.I0(acc_reg_i_18_0[3]),
        .I1(Q[3]),
        .I2(Q[2]),
        .I3(acc_reg_i_18_0[2]),
        .O(acc_reg_i_26_n_0));
  LUT4 #(
    .INIT(16'h44D4)) 
    acc_reg_i_27
       (.I0(acc_reg_i_18_0[1]),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(acc_reg_i_18_0[0]),
        .O(acc_reg_i_27_n_0));
  LUT4 #(
    .INIT(16'h9009)) 
    acc_reg_i_28
       (.I0(acc_reg_i_18_0[7]),
        .I1(Q[7]),
        .I2(Q[6]),
        .I3(acc_reg_i_18_0[6]),
        .O(acc_reg_i_28_n_0));
  LUT4 #(
    .INIT(16'h9009)) 
    acc_reg_i_29
       (.I0(Q[5]),
        .I1(acc_reg_i_18_0[5]),
        .I2(Q[4]),
        .I3(acc_reg_i_18_0[4]),
        .O(acc_reg_i_29_n_0));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_2__5
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[6]),
        .O(b_in[6]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_2__8
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[8]),
        .O(A[8]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_2__9
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[8]),
        .O(acc_reg_i_2__9_n_0));
  LUT4 #(
    .INIT(16'h9009)) 
    acc_reg_i_30
       (.I0(Q[3]),
        .I1(acc_reg_i_18_0[3]),
        .I2(Q[2]),
        .I3(acc_reg_i_18_0[2]),
        .O(acc_reg_i_30_n_0));
  LUT4 #(
    .INIT(16'h9009)) 
    acc_reg_i_31
       (.I0(Q[1]),
        .I1(acc_reg_i_18_0[1]),
        .I2(Q[0]),
        .I3(acc_reg_i_18_0[0]),
        .O(acc_reg_i_31_n_0));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_3__0
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[5]),
        .O(b_in[5]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_4
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[4]),
        .O(b_in[4]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_5
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[3]),
        .O(b_in[3]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_6
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[2]),
        .O(b_in[2]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_7
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[1]),
        .O(b_in[1]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_8
       (.I0(\a_out_reg[8]_0 ),
        .I1(\a_out_reg[8]_1 ),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[0]),
        .O(b_in[0]));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_0
   (en,
    A,
    a_out,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    CO,
    last_seen,
    in_valid,
    a_col,
    pe_rst,
    E,
    a_in,
    clk,
    Q,
    acc_reg_2,
    b_in,
    acc_reg_3);
  output en;
  output [0:0]A;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input [0:0]CO;
  input last_seen;
  input in_valid;
  input [0:0]a_col;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]Q;
  input acc_reg_2;
  input [7:0]b_in;
  input [8:0]acc_reg_3;

  wire [0:0]A;
  wire [0:0]CO;
  wire [0:0]E;
  wire [7:0]Q;
  wire [0:0]a_col;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [8:0]acc_reg_3;
  wire acc_reg_i_1__23_n_0;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire in_valid;
  wire last_seen;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(1),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(1),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(1),
    .BREG(1),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({A,A,A,A,A,A,A,A,acc_reg_i_1__23_n_0,acc_reg_i_1__23_n_0,acc_reg_i_1__23_n_0,acc_reg_i_1__23_n_0,acc_reg_i_1__23_n_0,acc_reg_i_1__23_n_0,acc_reg_i_1__23_n_0,acc_reg_i_1__23_n_0,acc_reg_i_1__23_n_0,acc_reg_i_1__23_n_0,acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b0),
        .CEA2(acc_reg_2),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b0),
        .CEB2(1'b1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_11__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col),
        .O(A));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_1__23
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col),
        .O(acc_reg_i_1__23_n_0));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_2__2
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(en));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_1
   (b_in,
    a_out,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    CO,
    last_seen,
    in_valid,
    b_row,
    a_col,
    pe_rst,
    E,
    a_in,
    clk,
    Q,
    acc_reg_2,
    acc_reg_3,
    en,
    A);
  output [7:0]b_in;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input [0:0]CO;
  input last_seen;
  input in_valid;
  input [7:0]b_row;
  input [0:0]a_col;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]Q;
  input acc_reg_2;
  input acc_reg_3;
  input en;
  input [8:0]A;

  wire [8:0]A;
  wire [0:0]CO;
  wire [0:0]E;
  wire [7:0]Q;
  wire [0:0]a_col;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire acc_reg_3;
  wire acc_reg_i_10__1_n_0;
  wire acc_reg_i_9__1_n_0;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [7:0]b_row;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire in_valid;
  wire last_seen;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_i_9__1_n_0,acc_reg_i_9__1_n_0,acc_reg_i_9__1_n_0,acc_reg_i_9__1_n_0,acc_reg_i_9__1_n_0,acc_reg_i_9__1_n_0,acc_reg_i_9__1_n_0,acc_reg_i_9__1_n_0,acc_reg_i_9__1_n_0,acc_reg_i_9__1_n_0,acc_reg_i_10__1_n_0,acc_reg_i_10__1_n_0,acc_reg_i_10__1_n_0,acc_reg_i_10__1_n_0,acc_reg_i_10__1_n_0,acc_reg_i_10__1_n_0,acc_reg_i_10__1_n_0,acc_reg_i_10__1_n_0,acc_reg_i_10__1_n_0,acc_reg_i_10__1_n_0,A[8],A}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_2),
        .CEA2(acc_reg_3),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(1'b1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_10__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col),
        .O(acc_reg_i_10__1_n_0));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_1__22
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[7]),
        .O(b_in[7]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_2__7
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[6]),
        .O(b_in[6]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_3__2
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[5]),
        .O(b_in[5]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_4__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[4]),
        .O(b_in[4]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_5__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[3]),
        .O(b_in[3]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_6__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[2]),
        .O(b_in[2]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_7__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[1]),
        .O(b_in[1]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_8__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[0]),
        .O(b_in[0]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_9__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col),
        .O(acc_reg_i_9__1_n_0));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_10
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_0,
    acc_reg_1,
    en,
    Q,
    acc_reg_2);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]Q;
  input [8:0]acc_reg_2;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [8:0]acc_reg_2;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_11
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_0,
    acc_reg_1,
    en,
    Q,
    acc_reg_2);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]Q;
  input [8:0]acc_reg_2;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [8:0]acc_reg_2;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_12
   (b_out,
    c_flat,
    pe_rst,
    E,
    b_in,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    acc_reg_2,
    a_in);
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [7:0]b_in;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]acc_reg_2;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]acc_reg_2;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_13
   (\state_reg[0] ,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    b_in,
    clk,
    acc_reg_2,
    en,
    acc_reg_3,
    a_in);
  output \state_reg[0] ;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [7:0]b_in;
  input clk;
  input acc_reg_2;
  input en;
  input [7:0]acc_reg_3;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]acc_reg_3;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_2),
        .CEA2(\state_reg[0] ),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(\state_reg[0] ),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__14
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_14
   (b_out,
    c_flat,
    pe_rst,
    E,
    b_in,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    acc_reg_2,
    a_in);
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [7:0]b_in;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]acc_reg_2;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]acc_reg_2;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_15
   (a_in,
    a_out,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    CO,
    last_seen,
    in_valid,
    a_col,
    pe_rst,
    E,
    Q,
    clk,
    b_in,
    acc_reg_2,
    acc_reg_3,
    en,
    acc_reg_4);
  output [8:0]a_in;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input [0:0]CO;
  input last_seen;
  input in_valid;
  input [8:0]a_col;
  input pe_rst;
  input [0:0]E;
  input [8:0]Q;
  input clk;
  input [7:0]b_in;
  input acc_reg_2;
  input acc_reg_3;
  input en;
  input [7:0]acc_reg_4;

  wire [0:0]CO;
  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_col;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire acc_reg_3;
  wire [7:0]acc_reg_4;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire in_valid;
  wire last_seen;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(Q[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_4[7],acc_reg_4[7],acc_reg_4[7],acc_reg_4[7],acc_reg_4[7],acc_reg_4[7],acc_reg_4[7],acc_reg_4[7],acc_reg_4[7],acc_reg_4[7],acc_reg_4}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(1'b1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_2),
        .CEB2(acc_reg_3),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_10__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[7]),
        .O(a_in[7]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_11__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[6]),
        .O(a_in[6]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_12__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[5]),
        .O(a_in[5]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_13__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[4]),
        .O(a_in[4]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_14__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[3]),
        .O(a_in[3]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_15__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[2]),
        .O(a_in[2]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_16__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[1]),
        .O(a_in[1]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_17__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[0]),
        .O(a_in[0]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_9__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[8]),
        .O(a_in[8]));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_16
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_0,
    acc_reg_1,
    en,
    Q,
    acc_reg_2);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]Q;
  input [8:0]acc_reg_2;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [8:0]acc_reg_2;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(acc_reg_0),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_1),
        .CEB2(acc_reg_0),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_17
   (\state_reg[0] ,
    en,
    a_out,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_2,
    Q,
    acc_reg_3);
  output \state_reg[0] ;
  output en;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_2;
  input [7:0]Q;
  input [8:0]acc_reg_3;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [8:0]acc_reg_3;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(\state_reg[0] ),
        .CEA2(acc_reg_2),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(\state_reg[0] ),
        .CEB2(acc_reg_2),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__7
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_2__3
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(en));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_18
   (\state_reg[0] ,
    a_out,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_2,
    acc_reg_3,
    en,
    Q,
    acc_reg_4);
  output \state_reg[0] ;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_2;
  input acc_reg_3;
  input en;
  input [7:0]Q;
  input [8:0]acc_reg_4;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire acc_reg_3;
  wire [8:0]acc_reg_4;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(\state_reg[0] ),
        .CEA2(acc_reg_2),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(\state_reg[0] ),
        .CEB2(acc_reg_3),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__6
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_19
   (\state_reg[0] ,
    a_out,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_2,
    en,
    Q,
    acc_reg_3);
  output \state_reg[0] ;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_2;
  input en;
  input [7:0]Q;
  input [8:0]acc_reg_3;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [8:0]acc_reg_3;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_2),
        .CEA2(\state_reg[0] ),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_2),
        .CEB2(\state_reg[0] ),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__13
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_2
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    Q,
    acc_reg_0,
    acc_reg_1,
    en,
    acc_reg_2);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [15:0]Q;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [8:0]acc_reg_2;

  wire [0:0]E;
  wire [15:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [8:0]acc_reg_2;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7:0]}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(1'b1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[8]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[9]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[10]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[11]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[12]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[13]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[14]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[15]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_20
   (en,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    b_in,
    clk,
    acc_reg_2,
    acc_reg_3,
    Q,
    a_in);
  output en;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [7:0]b_in;
  input clk;
  input acc_reg_2;
  input acc_reg_3;
  input [7:0]Q;
  input [8:0]a_in;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire acc_reg_3;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_2),
        .CEA2(acc_reg_3),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_2),
        .CEB2(acc_reg_3),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__17
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(en));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_21
   (b_out,
    c_flat,
    pe_rst,
    E,
    b_in,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    Q,
    a_in);
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [7:0]b_in;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]Q;
  input [8:0]a_in;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_22
   (b_out,
    c_flat,
    pe_rst,
    E,
    b_in,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    Q,
    a_in);
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [7:0]b_in;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]Q;
  input [8:0]a_in;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_23
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    Q,
    clk,
    b_in,
    acc_reg_0,
    acc_reg_1,
    en,
    acc_reg_2);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [17:0]Q;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]acc_reg_2;

  wire [0:0]E;
  wire [17:0]Q;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]acc_reg_2;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[9]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[10]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[11]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[12]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[13]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[14]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[15]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[16]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(Q[17]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8:0]}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(1'b1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_24
   (\state_reg[0] ,
    a_out,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_2,
    en,
    acc_reg_3,
    Q);
  output \state_reg[0] ;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_2;
  input en;
  input [7:0]acc_reg_3;
  input [8:0]Q;

  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]acc_reg_3;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(\state_reg[0] ),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_2),
        .CEB2(\state_reg[0] ),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_2__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_25
   (\state_reg[0] ,
    a_out,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_2,
    en,
    acc_reg_3,
    Q);
  output \state_reg[0] ;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_2;
  input en;
  input [7:0]acc_reg_3;
  input [8:0]Q;

  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]acc_reg_3;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(\state_reg[0] ),
        .CEA2(acc_reg_2),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(\state_reg[0] ),
        .CEB2(acc_reg_2),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__5
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_26
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_0,
    acc_reg_1,
    en,
    acc_reg_2,
    acc_reg_3);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]acc_reg_2;
  input [8:0]acc_reg_3;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]acc_reg_2;
  wire [8:0]acc_reg_3;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_27
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_0,
    acc_reg_1,
    en,
    acc_reg_2,
    acc_reg_3);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]acc_reg_2;
  input [8:0]acc_reg_3;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]acc_reg_2;
  wire [8:0]acc_reg_3;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_28
   (b_out,
    c_flat,
    pe_rst,
    E,
    \b_out_reg[7]_0 ,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    b_in,
    a_in);
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [7:0]\b_out_reg[7]_0 ;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [7:0]\b_out_reg[7]_0 ;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_29
   (\state_reg[0] ,
    \state_reg[0]_0 ,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    \b_out_reg[7]_0 ,
    clk,
    en,
    b_in,
    a_in);
  output \state_reg[0] ;
  output \state_reg[0]_0 ;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [7:0]\b_out_reg[7]_0 ;
  input clk;
  input en;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [7:0]\b_out_reg[7]_0 ;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire \state_reg[0]_0 ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(\state_reg[0] ),
        .CEA2(\state_reg[0]_0 ),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(\state_reg[0] ),
        .CEB2(\state_reg[0]_0 ),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__4
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_2__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0]_0 ));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_3
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    Q,
    acc_reg_0,
    acc_reg_1,
    en,
    acc_reg_2);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [15:0]Q;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [8:0]acc_reg_2;

  wire [0:0]E;
  wire [15:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [8:0]acc_reg_2;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7:0]}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(1'b1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[8]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[9]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[10]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[11]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[12]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[13]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[14]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[15]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_30
   (b_out,
    c_flat,
    pe_rst,
    E,
    \b_out_reg[7]_0 ,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    b_in,
    a_in);
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [7:0]\b_out_reg[7]_0 ;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [7:0]\b_out_reg[7]_0 ;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_31
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    Q,
    clk,
    b_in,
    acc_reg_0,
    acc_reg_1,
    en,
    acc_reg_2);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [17:0]Q;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]acc_reg_2;

  wire [0:0]E;
  wire [17:0]Q;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]acc_reg_2;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[9]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[10]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[11]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[12]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[13]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[14]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[15]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[16]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(Q[17]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8:0]}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(1'b1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_32
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_0,
    acc_reg_1,
    en,
    acc_reg_2,
    Q);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]acc_reg_2;
  input [8:0]Q;

  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]acc_reg_2;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(acc_reg_0),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_1),
        .CEB2(acc_reg_0),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_33
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_0,
    acc_reg_1,
    en,
    acc_reg_2,
    Q);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]acc_reg_2;
  input [8:0]Q;

  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]acc_reg_2;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2[7],acc_reg_2}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_34
   (E,
    a_out,
    b_out,
    c_flat,
    \b_out_reg[0]_0 ,
    \b_out_reg[0]_1 ,
    pe_rst,
    a_in,
    clk,
    b_in,
    acc_reg_0,
    acc_reg_1,
    acc_reg_2,
    en,
    acc_reg_3,
    acc_reg_4);
  output [0:0]E;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input \b_out_reg[0]_0 ;
  input \b_out_reg[0]_1 ;
  input pe_rst;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input acc_reg_1;
  input acc_reg_2;
  input en;
  input [7:0]acc_reg_3;
  input [8:0]acc_reg_4;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]acc_reg_3;
  wire [8:0]acc_reg_4;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire \b_out_reg[0]_0 ;
  wire \b_out_reg[0]_1 ;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4[8],acc_reg_4}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3[7],acc_reg_3}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_2),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
  LUT2 #(
    .INIT(4'h2)) 
    busy_INST_0
       (.I0(\b_out_reg[0]_0 ),
        .I1(\b_out_reg[0]_1 ),
        .O(E));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_35
   (\state_reg[0] ,
    \state_reg[0]_0 ,
    pe_rst,
    a_out,
    b_out,
    c_flat,
    \b_out_reg[0]_0 ,
    \b_out_reg[0]_1 ,
    start,
    rst,
    E,
    a_in,
    clk,
    b_in,
    en,
    acc_reg_0,
    acc_reg_1);
  output \state_reg[0] ;
  output \state_reg[0]_0 ;
  output pe_rst;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input \b_out_reg[0]_0 ;
  input \b_out_reg[0]_1 ;
  input start;
  input rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input en;
  input [7:0]acc_reg_0;
  input [8:0]acc_reg_1;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire [7:0]acc_reg_0;
  wire [8:0]acc_reg_1;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire \b_out_reg[0]_0 ;
  wire \b_out_reg[0]_1 ;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire rst;
  wire start;
  wire \state_reg[0] ;
  wire \state_reg[0]_0 ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1[8],acc_reg_1}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_0[7],acc_reg_0[7],acc_reg_0[7],acc_reg_0[7],acc_reg_0[7],acc_reg_0[7],acc_reg_0[7],acc_reg_0[7],acc_reg_0[7],acc_reg_0[7],acc_reg_0}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(\state_reg[0] ),
        .CEA2(\state_reg[0]_0 ),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(\state_reg[0] ),
        .CEB2(\state_reg[0]_0 ),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__12
       (.I0(\b_out_reg[0]_0 ),
        .I1(\b_out_reg[0]_1 ),
        .O(\state_reg[0]_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__3
       (.I0(\b_out_reg[0]_0 ),
        .I1(\b_out_reg[0]_1 ),
        .O(\state_reg[0] ));
  LUT4 #(
    .INIT(16'hFFD0)) 
    acc_reg_i_4__2
       (.I0(\b_out_reg[0]_0 ),
        .I1(\b_out_reg[0]_1 ),
        .I2(start),
        .I3(rst),
        .O(pe_rst));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_36
   (b_out,
    c_flat,
    pe_rst,
    E,
    \b_out_reg[7]_0 ,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    b_in,
    a_in);
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [7:0]\b_out_reg[7]_0 ;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [7:0]\b_out_reg[7]_0 ;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_37
   (en,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    \b_out_reg[7]_0 ,
    clk,
    acc_reg_2,
    acc_reg_3,
    b_in,
    a_in);
  output en;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [7:0]\b_out_reg[7]_0 ;
  input clk;
  input acc_reg_2;
  input acc_reg_3;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire acc_reg_3;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [7:0]\b_out_reg[7]_0 ;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_2),
        .CEA2(acc_reg_3),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_2),
        .CEB2(acc_reg_3),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__18
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(en));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_38
   (b_out,
    c_flat,
    pe_rst,
    E,
    \b_out_reg[7]_0 ,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    b_in,
    a_in);
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [7:0]\b_out_reg[7]_0 ;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [7:0]\b_out_reg[7]_0 ;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_39
   (a_in,
    a_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    acc_reg_2,
    acc_reg_3,
    acc_reg_4,
    acc_reg_5,
    acc_reg_6,
    acc_reg_7,
    acc_reg_8,
    acc_reg_9,
    pe_rst,
    E,
    Q,
    clk,
    acc_reg_10,
    acc_reg_11,
    en,
    b_in);
  output [8:0]a_in;
  output [8:0]a_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input acc_reg_2;
  input acc_reg_3;
  input acc_reg_4;
  input acc_reg_5;
  input acc_reg_6;
  input acc_reg_7;
  input acc_reg_8;
  input acc_reg_9;
  input pe_rst;
  input [0:0]E;
  input [8:0]Q;
  input clk;
  input acc_reg_10;
  input acc_reg_11;
  input en;
  input [7:0]b_in;

  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_10;
  wire acc_reg_11;
  wire acc_reg_2;
  wire acc_reg_3;
  wire acc_reg_4;
  wire acc_reg_5;
  wire acc_reg_6;
  wire acc_reg_7;
  wire acc_reg_8;
  wire acc_reg_9;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(Q[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(1'b1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_10),
        .CEB2(acc_reg_11),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(a_in[8]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__0
       (.I0(acc_reg_2),
        .I1(acc_reg_1),
        .O(a_in[7]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__1
       (.I0(acc_reg_3),
        .I1(acc_reg_1),
        .O(a_in[6]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__2
       (.I0(acc_reg_4),
        .I1(acc_reg_1),
        .O(a_in[5]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__3
       (.I0(acc_reg_5),
        .I1(acc_reg_1),
        .O(a_in[4]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__4
       (.I0(acc_reg_6),
        .I1(acc_reg_1),
        .O(a_in[3]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__5
       (.I0(acc_reg_7),
        .I1(acc_reg_1),
        .O(a_in[2]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__6
       (.I0(acc_reg_8),
        .I1(acc_reg_1),
        .O(a_in[1]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__7
       (.I0(acc_reg_9),
        .I1(acc_reg_1),
        .O(a_in[0]));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_4
   (b_in,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    acc_reg_2,
    acc_reg_3,
    acc_reg_4,
    acc_reg_5,
    acc_reg_6,
    acc_reg_7,
    acc_reg_8,
    pe_rst,
    E,
    Q,
    clk,
    acc_reg_9,
    acc_reg_10,
    en,
    a_in);
  output [7:0]b_in;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input acc_reg_2;
  input acc_reg_3;
  input acc_reg_4;
  input acc_reg_5;
  input acc_reg_6;
  input acc_reg_7;
  input acc_reg_8;
  input pe_rst;
  input [0:0]E;
  input [7:0]Q;
  input clk;
  input acc_reg_9;
  input acc_reg_10;
  input en;
  input [8:0]a_in;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_10;
  wire acc_reg_2;
  wire acc_reg_3;
  wire acc_reg_4;
  wire acc_reg_5;
  wire acc_reg_6;
  wire acc_reg_7;
  wire acc_reg_8;
  wire acc_reg_9;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_9),
        .CEA2(acc_reg_10),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(1'b1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[7]),
        .Q(b_out[7]),
        .R(pe_rst));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(b_in[7]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__0
       (.I0(acc_reg_2),
        .I1(acc_reg_1),
        .O(b_in[6]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__1
       (.I0(acc_reg_3),
        .I1(acc_reg_1),
        .O(b_in[5]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__2
       (.I0(acc_reg_4),
        .I1(acc_reg_1),
        .O(b_in[4]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__3
       (.I0(acc_reg_5),
        .I1(acc_reg_1),
        .O(b_in[3]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__4
       (.I0(acc_reg_6),
        .I1(acc_reg_1),
        .O(b_in[2]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__5
       (.I0(acc_reg_7),
        .I1(acc_reg_1),
        .O(b_in[1]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__6
       (.I0(acc_reg_8),
        .I1(acc_reg_1),
        .O(b_in[0]));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_40
   (\state_reg[0] ,
    en,
    a_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    a_in,
    clk,
    acc_reg_2,
    b_in,
    acc_reg_3);
  output \state_reg[0] ;
  output en;
  output [8:0]a_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input acc_reg_2;
  input [7:0]b_in;
  input [8:0]acc_reg_3;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [8:0]acc_reg_3;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(\state_reg[0] ),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_2),
        .CEB2(\state_reg[0] ),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__11
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__16
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(en));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_41
   (\state_reg[0] ,
    a_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    a_in,
    clk,
    acc_reg_2,
    en,
    b_in,
    Q);
  output \state_reg[0] ;
  output [8:0]a_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input acc_reg_2;
  input en;
  input [7:0]b_in;
  input [8:0]Q;

  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(\state_reg[0] ),
        .CEA2(acc_reg_2),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(\state_reg[0] ),
        .CEB2(acc_reg_2),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__2
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_42
   (a_out,
    c_flat,
    pe_rst,
    E,
    \a_out_reg[8]_0 ,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    b_in,
    a_in);
  output [8:0]a_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]\a_out_reg[8]_0 ;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire [8:0]\a_out_reg[8]_0 ;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_43
   (a_out,
    c_flat,
    pe_rst,
    E,
    \a_out_reg[8]_0 ,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    b_in,
    a_in);
  output [8:0]a_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]\a_out_reg[8]_0 ;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire [8:0]\a_out_reg[8]_0 ;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_44
   (c_flat,
    acc_reg_0,
    acc_reg_1,
    en,
    clk,
    pe_rst,
    b_out,
    a_out);
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input clk;
  input pe_rst;
  input [7:0]b_out;
  input [8:0]a_out;

  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_45
   (c_flat,
    \state_reg[0] ,
    acc_reg_0,
    en,
    clk,
    pe_rst,
    b_out,
    a_out,
    acc_reg_1,
    acc_reg_2);
  output [31:0]c_flat;
  output \state_reg[0] ;
  input acc_reg_0;
  input en;
  input clk;
  input pe_rst;
  input [7:0]b_out;
  input [8:0]a_out;
  input acc_reg_1;
  input acc_reg_2;

  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(\state_reg[0] ),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(\state_reg[0] ),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__10
       (.I0(acc_reg_1),
        .I1(acc_reg_2),
        .O(\state_reg[0] ));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_46
   (c_flat,
    \state_reg[0] ,
    acc_reg_0,
    en,
    clk,
    pe_rst,
    b_out,
    a_out,
    acc_reg_1,
    acc_reg_2);
  output [31:0]c_flat;
  output \state_reg[0] ;
  input acc_reg_0;
  input en;
  input clk;
  input pe_rst;
  input [7:0]b_out;
  input [8:0]a_out;
  input acc_reg_1;
  input acc_reg_2;

  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(\state_reg[0] ),
        .CEA2(acc_reg_0),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(\state_reg[0] ),
        .CEB2(acc_reg_0),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__1
       (.I0(acc_reg_1),
        .I1(acc_reg_2),
        .O(\state_reg[0] ));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_47
   (a_in,
    a_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    acc_reg_2,
    acc_reg_3,
    acc_reg_4,
    acc_reg_5,
    acc_reg_6,
    acc_reg_7,
    acc_reg_8,
    acc_reg_9,
    pe_rst,
    E,
    Q,
    clk,
    acc_reg_10,
    acc_reg_11,
    en,
    b_in);
  output [8:0]a_in;
  output [8:0]a_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input acc_reg_2;
  input acc_reg_3;
  input acc_reg_4;
  input acc_reg_5;
  input acc_reg_6;
  input acc_reg_7;
  input acc_reg_8;
  input acc_reg_9;
  input pe_rst;
  input [0:0]E;
  input [8:0]Q;
  input clk;
  input acc_reg_10;
  input acc_reg_11;
  input en;
  input [7:0]b_in;

  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_10;
  wire acc_reg_11;
  wire acc_reg_2;
  wire acc_reg_3;
  wire acc_reg_4;
  wire acc_reg_5;
  wire acc_reg_6;
  wire acc_reg_7;
  wire acc_reg_8;
  wire acc_reg_9;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(Q[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(1'b1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_10),
        .CEB2(acc_reg_11),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__10
       (.I0(acc_reg_3),
        .I1(acc_reg_1),
        .O(a_in[6]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__11
       (.I0(acc_reg_4),
        .I1(acc_reg_1),
        .O(a_in[5]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__12
       (.I0(acc_reg_5),
        .I1(acc_reg_1),
        .O(a_in[4]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__13
       (.I0(acc_reg_6),
        .I1(acc_reg_1),
        .O(a_in[3]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__14
       (.I0(acc_reg_7),
        .I1(acc_reg_1),
        .O(a_in[2]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__15
       (.I0(acc_reg_8),
        .I1(acc_reg_1),
        .O(a_in[1]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__16
       (.I0(acc_reg_9),
        .I1(acc_reg_1),
        .O(a_in[0]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__8
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(a_in[8]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__9
       (.I0(acc_reg_2),
        .I1(acc_reg_1),
        .O(a_in[7]));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_48
   (a_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    b_in,
    acc_reg_2);
  output [8:0]a_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]b_in;
  input [8:0]acc_reg_2;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [8:0]acc_reg_2;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(acc_reg_0),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_1),
        .CEB2(acc_reg_0),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_49
   (a_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    b_in,
    Q);
  output [8:0]a_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]b_in;
  input [8:0]Q;

  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_5
   (b_in,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    acc_reg_2,
    acc_reg_3,
    acc_reg_4,
    acc_reg_5,
    acc_reg_6,
    acc_reg_7,
    acc_reg_8,
    pe_rst,
    E,
    Q,
    clk,
    acc_reg_9,
    acc_reg_10,
    en,
    a_in);
  output [7:0]b_in;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input acc_reg_2;
  input acc_reg_3;
  input acc_reg_4;
  input acc_reg_5;
  input acc_reg_6;
  input acc_reg_7;
  input acc_reg_8;
  input pe_rst;
  input [0:0]E;
  input [7:0]Q;
  input clk;
  input acc_reg_9;
  input acc_reg_10;
  input en;
  input [8:0]a_in;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_10;
  wire acc_reg_2;
  wire acc_reg_3;
  wire acc_reg_4;
  wire acc_reg_5;
  wire acc_reg_6;
  wire acc_reg_7;
  wire acc_reg_8;
  wire acc_reg_9;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_9),
        .CEA2(acc_reg_10),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(1'b1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[7]),
        .Q(b_out[7]),
        .R(pe_rst));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__10
       (.I0(acc_reg_4),
        .I1(acc_reg_1),
        .O(b_in[4]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__11
       (.I0(acc_reg_5),
        .I1(acc_reg_1),
        .O(b_in[3]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__12
       (.I0(acc_reg_6),
        .I1(acc_reg_1),
        .O(b_in[2]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__13
       (.I0(acc_reg_7),
        .I1(acc_reg_1),
        .O(b_in[1]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__14
       (.I0(acc_reg_8),
        .I1(acc_reg_1),
        .O(b_in[0]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__7
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(b_in[7]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__8
       (.I0(acc_reg_2),
        .I1(acc_reg_1),
        .O(b_in[6]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__9
       (.I0(acc_reg_3),
        .I1(acc_reg_1),
        .O(b_in[5]));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_50
   (a_out,
    c_flat,
    pe_rst,
    E,
    \a_out_reg[8]_0 ,
    clk,
    acc_reg_0,
    acc_reg_1,
    acc_reg_2,
    en,
    b_in,
    a_in);
  output [8:0]a_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]\a_out_reg[8]_0 ;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input acc_reg_2;
  input en;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire [8:0]\a_out_reg[8]_0 ;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_2),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_51
   (\state_reg[0] ,
    a_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    \a_out_reg[8]_0 ,
    clk,
    acc_reg_2,
    en,
    b_in,
    a_in);
  output \state_reg[0] ;
  output [8:0]a_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [8:0]\a_out_reg[8]_0 ;
  input clk;
  input acc_reg_2;
  input en;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire [8:0]\a_out_reg[8]_0 ;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_2),
        .CEA2(\state_reg[0] ),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_2),
        .CEB2(\state_reg[0] ),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__9
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_52
   (c_flat,
    \state_reg[0] ,
    acc_reg_0,
    en,
    clk,
    pe_rst,
    b_out,
    a_out,
    acc_reg_1,
    acc_reg_2);
  output [31:0]c_flat;
  output \state_reg[0] ;
  input acc_reg_0;
  input en;
  input clk;
  input pe_rst;
  input [7:0]b_out;
  input [8:0]a_out;
  input acc_reg_1;
  input acc_reg_2;

  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(\state_reg[0] ),
        .CEA2(acc_reg_0),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(\state_reg[0] ),
        .CEB2(acc_reg_0),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__0
       (.I0(acc_reg_1),
        .I1(acc_reg_2),
        .O(\state_reg[0] ));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_53
   (c_flat,
    acc_reg_0,
    acc_reg_1,
    en,
    clk,
    pe_rst,
    b_out,
    a_out);
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input clk;
  input pe_rst;
  input [7:0]b_out;
  input [8:0]a_out;

  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_54
   (c_flat,
    acc_reg_0,
    acc_reg_1,
    en,
    clk,
    pe_rst,
    b_out,
    a_out);
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input clk;
  input pe_rst;
  input [7:0]b_out;
  input [8:0]a_out;

  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_55
   (a_in,
    a_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    acc_reg_2,
    acc_reg_3,
    acc_reg_4,
    acc_reg_5,
    acc_reg_6,
    acc_reg_7,
    acc_reg_8,
    acc_reg_9,
    pe_rst,
    E,
    Q,
    clk,
    acc_reg_10,
    acc_reg_11,
    en,
    b_in);
  output [8:0]a_in;
  output [8:0]a_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input acc_reg_2;
  input acc_reg_3;
  input acc_reg_4;
  input acc_reg_5;
  input acc_reg_6;
  input acc_reg_7;
  input acc_reg_8;
  input acc_reg_9;
  input pe_rst;
  input [0:0]E;
  input [8:0]Q;
  input clk;
  input acc_reg_10;
  input acc_reg_11;
  input en;
  input [7:0]b_in;

  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_10;
  wire acc_reg_11;
  wire acc_reg_2;
  wire acc_reg_3;
  wire acc_reg_4;
  wire acc_reg_5;
  wire acc_reg_6;
  wire acc_reg_7;
  wire acc_reg_8;
  wire acc_reg_9;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(Q[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(1'b1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_10),
        .CEB2(acc_reg_11),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__17
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(a_in[8]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__18
       (.I0(acc_reg_2),
        .I1(acc_reg_1),
        .O(a_in[7]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__19
       (.I0(acc_reg_3),
        .I1(acc_reg_1),
        .O(a_in[6]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__20
       (.I0(acc_reg_4),
        .I1(acc_reg_1),
        .O(a_in[5]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__21
       (.I0(acc_reg_5),
        .I1(acc_reg_1),
        .O(a_in[4]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__22
       (.I0(acc_reg_6),
        .I1(acc_reg_1),
        .O(a_in[3]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__23
       (.I0(acc_reg_7),
        .I1(acc_reg_1),
        .O(a_in[2]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__24
       (.I0(acc_reg_8),
        .I1(acc_reg_1),
        .O(a_in[1]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_a_gate__25
       (.I0(acc_reg_9),
        .I1(acc_reg_1),
        .O(a_in[0]));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_56
   (\state_reg[0] ,
    a_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    a_in,
    clk,
    acc_reg_2,
    en,
    b_in,
    acc_reg_3);
  output \state_reg[0] ;
  output [8:0]a_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input acc_reg_2;
  input en;
  input [7:0]b_in;
  input [8:0]acc_reg_3;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [8:0]acc_reg_3;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3[8],acc_reg_3}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(\state_reg[0] ),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_2),
        .CEB2(\state_reg[0] ),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__8
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_57
   (en,
    a_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    a_in,
    clk,
    acc_reg_2,
    acc_reg_3,
    b_in,
    Q);
  output en;
  output [8:0]a_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input acc_reg_2;
  input acc_reg_3;
  input [7:0]b_in;
  input [8:0]Q;

  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire acc_reg_3;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q[8],Q}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_2),
        .CEA2(acc_reg_3),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_2),
        .CEB2(acc_reg_3),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_2__4
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(en));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_58
   (\state_reg[0] ,
    a_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    pe_rst,
    E,
    \a_out_reg[8]_0 ,
    clk,
    acc_reg_2,
    en,
    b_in,
    a_in);
  output \state_reg[0] ;
  output [8:0]a_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input pe_rst;
  input [0:0]E;
  input [8:0]\a_out_reg[8]_0 ;
  input clk;
  input acc_reg_2;
  input en;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire [8:0]\a_out_reg[8]_0 ;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(\state_reg[0] ),
        .CEA2(acc_reg_2),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(\state_reg[0] ),
        .CEB2(acc_reg_2),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_59
   (a_out,
    c_flat,
    pe_rst,
    E,
    \a_out_reg[8]_0 ,
    clk,
    acc_reg_0,
    acc_reg_1,
    en,
    b_in,
    a_in);
  output [8:0]a_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]\a_out_reg[8]_0 ;
  input clk;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]b_in;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire [8:0]\a_out_reg[8]_0 ;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_6
   (b_in,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    acc_reg_2,
    acc_reg_3,
    acc_reg_4,
    acc_reg_5,
    acc_reg_6,
    acc_reg_7,
    acc_reg_8,
    pe_rst,
    E,
    Q,
    clk,
    acc_reg_9,
    acc_reg_10,
    en,
    a_in);
  output [7:0]b_in;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input acc_reg_2;
  input acc_reg_3;
  input acc_reg_4;
  input acc_reg_5;
  input acc_reg_6;
  input acc_reg_7;
  input acc_reg_8;
  input pe_rst;
  input [0:0]E;
  input [7:0]Q;
  input clk;
  input acc_reg_9;
  input acc_reg_10;
  input en;
  input [8:0]a_in;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_10;
  wire acc_reg_2;
  wire acc_reg_3;
  wire acc_reg_4;
  wire acc_reg_5;
  wire acc_reg_6;
  wire acc_reg_7;
  wire acc_reg_8;
  wire acc_reg_9;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_9),
        .CEA2(acc_reg_10),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(1'b1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[7]),
        .Q(b_out[7]),
        .R(pe_rst));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__15
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(b_in[7]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__16
       (.I0(acc_reg_2),
        .I1(acc_reg_1),
        .O(b_in[6]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__17
       (.I0(acc_reg_3),
        .I1(acc_reg_1),
        .O(b_in[5]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__18
       (.I0(acc_reg_4),
        .I1(acc_reg_1),
        .O(b_in[4]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__19
       (.I0(acc_reg_5),
        .I1(acc_reg_1),
        .O(b_in[3]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__20
       (.I0(acc_reg_6),
        .I1(acc_reg_1),
        .O(b_in[2]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__21
       (.I0(acc_reg_7),
        .I1(acc_reg_1),
        .O(b_in[1]));
  LUT2 #(
    .INIT(4'h8)) 
    g_skew_b_gate__22
       (.I0(acc_reg_8),
        .I1(acc_reg_1),
        .O(b_in[0]));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_60
   (c_flat,
    \state_reg[0] ,
    acc_reg_0,
    acc_reg_1,
    clk,
    pe_rst,
    b_out,
    a_out,
    acc_reg_2,
    acc_reg_3);
  output [31:0]c_flat;
  output \state_reg[0] ;
  input acc_reg_0;
  input acc_reg_1;
  input clk;
  input pe_rst;
  input [7:0]b_out;
  input [8:0]a_out;
  input acc_reg_2;
  input acc_reg_3;

  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire acc_reg_3;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(\state_reg[0] ),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_3
       (.I0(acc_reg_2),
        .I1(acc_reg_3),
        .O(\state_reg[0] ));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_61
   (c_flat,
    \state_reg[0] ,
    en,
    acc_reg_0,
    clk,
    pe_rst,
    b_out,
    a_out,
    acc_reg_1,
    acc_reg_2);
  output [31:0]c_flat;
  output \state_reg[0] ;
  output en;
  input acc_reg_0;
  input clk;
  input pe_rst;
  input [7:0]b_out;
  input [8:0]a_out;
  input acc_reg_1;
  input acc_reg_2;

  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(\state_reg[0] ),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(\state_reg[0] ),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__19
       (.I0(acc_reg_1),
        .I1(acc_reg_2),
        .O(en));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_2
       (.I0(acc_reg_1),
        .I1(acc_reg_2),
        .O(\state_reg[0] ));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_62
   (c_flat,
    acc_reg_0,
    acc_reg_1,
    acc_reg_2,
    clk,
    pe_rst,
    b_out,
    a_out);
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input acc_reg_2;
  input clk;
  input pe_rst;
  input [7:0]b_out;
  input [8:0]a_out;

  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire acc_reg_2;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out[8],a_out}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out[7],b_out}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(acc_reg_0),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(acc_reg_2),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_7
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    Q,
    clk,
    b_in,
    acc_reg_0,
    en,
    acc_reg_1,
    a_in);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]Q;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input en;
  input [7:0]acc_reg_1;
  input [8:0]a_in;

  wire [0:0]E;
  wire [8:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire [7:0]acc_reg_1;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(Q[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(Q[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(Q[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(Q[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(Q[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(Q[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(Q[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(Q[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(Q[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(1),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(1),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(1),
    .BREG(1),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({acc_reg_1[7],acc_reg_1[7],acc_reg_1[7],acc_reg_1[7],acc_reg_1[7],acc_reg_1[7],acc_reg_1[7],acc_reg_1[7],acc_reg_1[7],acc_reg_1[7],acc_reg_1}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b0),
        .CEA2(1'b1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b0),
        .CEB2(acc_reg_0),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_8
   (\state_reg[0] ,
    b_in,
    a_in,
    a_out,
    b_out,
    c_flat,
    acc_reg_0,
    acc_reg_1,
    CO,
    last_seen,
    in_valid,
    b_row,
    a_col,
    pe_rst,
    E,
    \a_out_reg[8]_0 ,
    clk,
    \b_out_reg[7]_0 ,
    en);
  output \state_reg[0] ;
  output [7:0]b_in;
  output [8:0]a_in;
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input acc_reg_0;
  input acc_reg_1;
  input [0:0]CO;
  input last_seen;
  input in_valid;
  input [7:0]b_row;
  input [8:0]a_col;
  input pe_rst;
  input [0:0]E;
  input [8:0]\a_out_reg[8]_0 ;
  input clk;
  input [7:0]\b_out_reg[7]_0 ;
  input en;

  wire [0:0]CO;
  wire [0:0]E;
  wire [8:0]a_col;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire [8:0]\a_out_reg[8]_0 ;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [7:0]\b_out_reg[7]_0 ;
  wire [7:0]b_row;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire in_valid;
  wire last_seen;
  wire pe_rst;
  wire \state_reg[0] ;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(\a_out_reg[8]_0 [8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in[8],a_in}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in[7],b_in}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b1),
        .CEA2(\state_reg[0] ),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(\state_reg[0] ),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_10
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[7]),
        .O(a_in[7]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_11
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[6]),
        .O(a_in[6]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_12__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[5]),
        .O(a_in[5]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_13__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[4]),
        .O(a_in[4]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_14__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[3]),
        .O(a_in[3]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_15__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[2]),
        .O(a_in[2]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_16__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[1]),
        .O(a_in[1]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_17__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[0]),
        .O(a_in[0]));
  LUT2 #(
    .INIT(4'h2)) 
    acc_reg_i_1__15
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .O(\state_reg[0] ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_1__21
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[7]),
        .O(b_in[7]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_2__6
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[6]),
        .O(b_in[6]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_3__1
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[5]),
        .O(b_in[5]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_4__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[4]),
        .O(b_in[4]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_5__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[3]),
        .O(b_in[3]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_6__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[2]),
        .O(b_in[2]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_7__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[1]),
        .O(b_in[1]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_8__0
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[0]),
        .O(b_in[0]));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    acc_reg_i_9
       (.I0(acc_reg_0),
        .I1(acc_reg_1),
        .I2(CO),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[8]),
        .O(a_in[8]));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(\b_out_reg[7]_0 [7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ORIG_REF_NAME = "pe" *) 
module pe_9
   (a_out,
    b_out,
    c_flat,
    pe_rst,
    E,
    a_in,
    clk,
    b_in,
    acc_reg_0,
    acc_reg_1,
    en,
    Q,
    acc_reg_2);
  output [8:0]a_out;
  output [7:0]b_out;
  output [31:0]c_flat;
  input pe_rst;
  input [0:0]E;
  input [8:0]a_in;
  input clk;
  input [7:0]b_in;
  input acc_reg_0;
  input acc_reg_1;
  input en;
  input [7:0]Q;
  input [8:0]acc_reg_2;

  wire [0:0]E;
  wire [7:0]Q;
  wire [8:0]a_in;
  wire [8:0]a_out;
  wire acc_reg_0;
  wire acc_reg_1;
  wire [8:0]acc_reg_2;
  wire [7:0]b_in;
  wire [7:0]b_out;
  wire [31:0]c_flat;
  wire clk;
  wire en;
  wire pe_rst;
  wire NLW_acc_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_acc_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_acc_reg_OVERFLOW_UNCONNECTED;
  wire NLW_acc_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_acc_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_acc_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_acc_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_acc_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_acc_reg_CARRYOUT_UNCONNECTED;
  wire [47:32]NLW_acc_reg_P_UNCONNECTED;
  wire [47:0]NLW_acc_reg_PCOUT_UNCONNECTED;

  FDRE \a_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(a_in[0]),
        .Q(a_out[0]),
        .R(pe_rst));
  FDRE \a_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(a_in[1]),
        .Q(a_out[1]),
        .R(pe_rst));
  FDRE \a_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(a_in[2]),
        .Q(a_out[2]),
        .R(pe_rst));
  FDRE \a_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(a_in[3]),
        .Q(a_out[3]),
        .R(pe_rst));
  FDRE \a_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(a_in[4]),
        .Q(a_out[4]),
        .R(pe_rst));
  FDRE \a_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(a_in[5]),
        .Q(a_out[5]),
        .R(pe_rst));
  FDRE \a_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(a_in[6]),
        .Q(a_out[6]),
        .R(pe_rst));
  FDRE \a_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(a_in[7]),
        .Q(a_out[7]),
        .R(pe_rst));
  FDRE \a_out_reg[8] 
       (.C(clk),
        .CE(E),
        .D(a_in[8]),
        .Q(a_out[8]),
        .R(pe_rst));
  DSP48E1 #(
    .ACASCREG(2),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(2),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(2),
    .BREG(2),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    acc_reg
       (.A({acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2[8],acc_reg_2}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_acc_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q[7],Q}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_acc_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_acc_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_acc_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(acc_reg_0),
        .CEA2(acc_reg_1),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b1),
        .CEB2(acc_reg_1),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(en),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_acc_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b1,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_acc_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_acc_reg_P_UNCONNECTED[47:32],c_flat}),
        .PATTERNBDETECT(NLW_acc_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_acc_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_acc_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(pe_rst),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(pe_rst),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(pe_rst),
        .UNDERFLOW(NLW_acc_reg_UNDERFLOW_UNCONNECTED));
  FDRE \b_out_reg[0] 
       (.C(clk),
        .CE(E),
        .D(b_in[0]),
        .Q(b_out[0]),
        .R(pe_rst));
  FDRE \b_out_reg[1] 
       (.C(clk),
        .CE(E),
        .D(b_in[1]),
        .Q(b_out[1]),
        .R(pe_rst));
  FDRE \b_out_reg[2] 
       (.C(clk),
        .CE(E),
        .D(b_in[2]),
        .Q(b_out[2]),
        .R(pe_rst));
  FDRE \b_out_reg[3] 
       (.C(clk),
        .CE(E),
        .D(b_in[3]),
        .Q(b_out[3]),
        .R(pe_rst));
  FDRE \b_out_reg[4] 
       (.C(clk),
        .CE(E),
        .D(b_in[4]),
        .Q(b_out[4]),
        .R(pe_rst));
  FDRE \b_out_reg[5] 
       (.C(clk),
        .CE(E),
        .D(b_in[5]),
        .Q(b_out[5]),
        .R(pe_rst));
  FDRE \b_out_reg[6] 
       (.C(clk),
        .CE(E),
        .D(b_in[6]),
        .Q(b_out[6]),
        .R(pe_rst));
  FDRE \b_out_reg[7] 
       (.C(clk),
        .CE(E),
        .D(b_in[7]),
        .Q(b_out[7]),
        .R(pe_rst));
endmodule

(* ACC_W = "32" *) (* A_W = "9" *) (* B_W = "8" *) 
(* DRAIN = "14" *) (* D_W = "8" *) (* K_W = "11" *) 
(* N = "8" *) (* S_DONE = "2'b10" *) (* S_IDLE = "2'b00" *) 
(* S_RUN = "2'b01" *) 
(* NotValidForBitStream *)
module systolic_nxn
   (clk,
    rst,
    start,
    k_len,
    in_valid,
    a_col,
    b_row,
    c_flat,
    busy,
    done);
  input clk;
  input rst;
  input start;
  input [10:0]k_len;
  input in_valid;
  input [71:0]a_col;
  input [63:0]b_row;
  output [2047:0]c_flat;
  output busy;
  output done;

  wire [71:0]a_col;
  wire [8:0]\a_w[0] ;
  wire [8:0]\a_w[10] ;
  wire [8:0]\a_w[11] ;
  wire [8:0]\a_w[12] ;
  wire [8:0]\a_w[16] ;
  wire [8:0]\a_w[17] ;
  wire [8:0]\a_w[18] ;
  wire [8:0]\a_w[19] ;
  wire [8:0]\a_w[1] ;
  wire [8:0]\a_w[20] ;
  wire [8:0]\a_w[24] ;
  wire [8:0]\a_w[25] ;
  wire [8:0]\a_w[26] ;
  wire [8:0]\a_w[27] ;
  wire [8:0]\a_w[28] ;
  wire [8:0]\a_w[2] ;
  wire [8:0]\a_w[32] ;
  wire [8:0]\a_w[33] ;
  wire [8:0]\a_w[34] ;
  wire [8:0]\a_w[35] ;
  wire [8:0]\a_w[36] ;
  wire [8:0]\a_w[3] ;
  wire [8:0]\a_w[40] ;
  wire [8:0]\a_w[41] ;
  wire [8:0]\a_w[42] ;
  wire [8:0]\a_w[43] ;
  wire [8:0]\a_w[44] ;
  wire [8:0]\a_w[48] ;
  wire [8:0]\a_w[49] ;
  wire [8:0]\a_w[4] ;
  wire [8:0]\a_w[50] ;
  wire [8:0]\a_w[51] ;
  wire [8:0]\a_w[52] ;
  wire [8:0]\a_w[56] ;
  wire [8:0]\a_w[57] ;
  wire [8:0]\a_w[58] ;
  wire [8:0]\a_w[59] ;
  wire [8:0]\a_w[60] ;
  wire [8:0]\a_w[8] ;
  wire [8:0]\a_w[9] ;
  wire [63:0]b_row;
  wire [7:0]\b_w[0] ;
  wire [7:0]\b_w[10] ;
  wire [7:0]\b_w[11] ;
  wire [7:0]\b_w[12] ;
  wire [7:0]\b_w[13] ;
  wire [7:0]\b_w[14] ;
  wire [7:0]\b_w[15] ;
  wire [7:0]\b_w[16] ;
  wire [7:0]\b_w[17] ;
  wire [7:0]\b_w[18] ;
  wire [7:0]\b_w[19] ;
  wire [7:0]\b_w[1] ;
  wire [7:0]\b_w[20] ;
  wire [7:0]\b_w[21] ;
  wire [7:0]\b_w[22] ;
  wire [7:0]\b_w[23] ;
  wire [7:0]\b_w[24] ;
  wire [7:0]\b_w[25] ;
  wire [7:0]\b_w[26] ;
  wire [7:0]\b_w[27] ;
  wire [7:0]\b_w[28] ;
  wire [7:0]\b_w[29] ;
  wire [7:0]\b_w[2] ;
  wire [7:0]\b_w[30] ;
  wire [7:0]\b_w[31] ;
  wire [7:0]\b_w[32] ;
  wire [7:0]\b_w[33] ;
  wire [7:0]\b_w[34] ;
  wire [7:0]\b_w[35] ;
  wire [7:0]\b_w[36] ;
  wire [7:0]\b_w[37] ;
  wire [7:0]\b_w[38] ;
  wire [7:0]\b_w[39] ;
  wire [7:0]\b_w[3] ;
  wire [7:0]\b_w[4] ;
  wire [7:0]\b_w[5] ;
  wire [7:0]\b_w[6] ;
  wire [7:0]\b_w[7] ;
  wire [7:0]\b_w[8] ;
  wire [7:0]\b_w[9] ;
  wire busy;
  wire [2047:0]c_flat;
  wire clk;
  wire \dcnt[0]_i_1_n_0 ;
  wire \dcnt[7]_i_1_n_0 ;
  wire \dcnt[7]_i_3_n_0 ;
  wire [7:0]dcnt_reg;
  wire done;
  wire done_i_1_n_0;
  wire done_i_2_n_0;
  wire done_i_3_n_0;
  wire [7:0]\g_row[0].g_col[0].a_in ;
  wire [7:0]\g_row[0].g_col[0].b_in ;
  wire \g_row[0].g_col[0].u_pe_n_1 ;
  wire \g_row[0].g_col[1].u_pe_n_0 ;
  wire \g_row[0].g_col[1].u_pe_n_1 ;
  wire [7:0]\g_row[0].g_col[2].b_in ;
  wire \g_row[0].g_col[2].u_pe_n_0 ;
  wire \g_row[0].g_col[2].u_pe_n_1 ;
  wire \g_row[0].g_col[2].u_pe_n_2 ;
  wire \g_row[0].g_col[2].u_pe_n_3 ;
  wire \g_row[0].g_col[2].u_pe_n_4 ;
  wire \g_row[0].g_col[2].u_pe_n_5 ;
  wire \g_row[0].g_col[2].u_pe_n_6 ;
  wire \g_row[0].g_col[2].u_pe_n_7 ;
  wire [7:0]\g_row[0].g_col[3].b_in ;
  wire [7:0]\g_row[0].g_col[4].b_in ;
  wire [7:0]\g_row[0].g_col[5].b_in ;
  wire \g_row[0].g_col[5].u_pe_n_0 ;
  wire \g_row[0].g_col[5].u_pe_n_1 ;
  wire \g_row[0].g_col[5].u_pe_n_2 ;
  wire \g_row[0].g_col[5].u_pe_n_3 ;
  wire \g_row[0].g_col[5].u_pe_n_4 ;
  wire \g_row[0].g_col[5].u_pe_n_5 ;
  wire \g_row[0].g_col[5].u_pe_n_6 ;
  wire \g_row[0].g_col[5].u_pe_n_7 ;
  wire [7:0]\g_row[0].g_col[6].b_in ;
  wire \g_row[0].g_col[6].u_pe_n_0 ;
  wire \g_row[0].g_col[6].u_pe_n_1 ;
  wire \g_row[0].g_col[6].u_pe_n_2 ;
  wire \g_row[0].g_col[6].u_pe_n_3 ;
  wire \g_row[0].g_col[6].u_pe_n_4 ;
  wire \g_row[0].g_col[6].u_pe_n_5 ;
  wire \g_row[0].g_col[6].u_pe_n_6 ;
  wire \g_row[0].g_col[6].u_pe_n_7 ;
  wire [7:0]\g_row[0].g_col[7].b_in ;
  wire \g_row[0].g_col[7].u_pe_n_0 ;
  wire \g_row[0].g_col[7].u_pe_n_1 ;
  wire \g_row[0].g_col[7].u_pe_n_2 ;
  wire \g_row[0].g_col[7].u_pe_n_3 ;
  wire \g_row[0].g_col[7].u_pe_n_4 ;
  wire \g_row[0].g_col[7].u_pe_n_5 ;
  wire \g_row[0].g_col[7].u_pe_n_6 ;
  wire \g_row[0].g_col[7].u_pe_n_7 ;
  wire \g_row[1].g_col[1].u_pe_n_0 ;
  wire \g_row[1].g_col[1].u_pe_n_1 ;
  wire \g_row[1].g_col[1].u_pe_n_10 ;
  wire \g_row[1].g_col[1].u_pe_n_11 ;
  wire \g_row[1].g_col[1].u_pe_n_12 ;
  wire \g_row[1].g_col[1].u_pe_n_13 ;
  wire \g_row[1].g_col[1].u_pe_n_14 ;
  wire \g_row[1].g_col[1].u_pe_n_15 ;
  wire \g_row[1].g_col[1].u_pe_n_16 ;
  wire \g_row[1].g_col[1].u_pe_n_17 ;
  wire \g_row[1].g_col[1].u_pe_n_2 ;
  wire \g_row[1].g_col[1].u_pe_n_3 ;
  wire \g_row[1].g_col[1].u_pe_n_4 ;
  wire \g_row[1].g_col[1].u_pe_n_5 ;
  wire \g_row[1].g_col[1].u_pe_n_6 ;
  wire \g_row[1].g_col[1].u_pe_n_7 ;
  wire \g_row[1].g_col[1].u_pe_n_8 ;
  wire \g_row[1].g_col[1].u_pe_n_9 ;
  wire \g_row[1].g_col[6].u_pe_n_0 ;
  wire [8:0]\g_row[2].g_col[0].a_in ;
  wire \g_row[2].g_col[0].u_pe_n_0 ;
  wire \g_row[2].g_col[0].u_pe_n_1 ;
  wire \g_row[2].g_col[0].u_pe_n_2 ;
  wire \g_row[2].g_col[0].u_pe_n_3 ;
  wire \g_row[2].g_col[0].u_pe_n_4 ;
  wire \g_row[2].g_col[0].u_pe_n_5 ;
  wire \g_row[2].g_col[0].u_pe_n_6 ;
  wire \g_row[2].g_col[0].u_pe_n_7 ;
  wire \g_row[2].g_col[0].u_pe_n_8 ;
  wire \g_row[2].g_col[2].u_pe_n_0 ;
  wire \g_row[2].g_col[2].u_pe_n_1 ;
  wire \g_row[2].g_col[3].u_pe_n_0 ;
  wire \g_row[2].g_col[4].u_pe_n_0 ;
  wire \g_row[2].g_col[5].u_pe_n_0 ;
  wire [8:0]\g_row[3].g_col[0].a_in ;
  wire \g_row[3].g_col[1].u_pe_n_0 ;
  wire \g_row[3].g_col[2].u_pe_n_0 ;
  wire \g_row[3].g_col[6].u_pe_n_0 ;
  wire \g_row[3].g_col[6].u_pe_n_1 ;
  wire [8:0]\g_row[4].g_col[0].a_in ;
  wire \g_row[4].g_col[4].u_pe_n_0 ;
  wire \g_row[4].g_col[4].u_pe_n_1 ;
  wire \g_row[4].g_col[6].u_pe_n_0 ;
  wire [8:0]\g_row[5].g_col[0].a_in ;
  wire \g_row[5].g_col[0].u_pe_n_0 ;
  wire \g_row[5].g_col[0].u_pe_n_1 ;
  wire \g_row[5].g_col[0].u_pe_n_2 ;
  wire \g_row[5].g_col[0].u_pe_n_3 ;
  wire \g_row[5].g_col[0].u_pe_n_4 ;
  wire \g_row[5].g_col[0].u_pe_n_5 ;
  wire \g_row[5].g_col[0].u_pe_n_6 ;
  wire \g_row[5].g_col[0].u_pe_n_7 ;
  wire \g_row[5].g_col[0].u_pe_n_8 ;
  wire \g_row[5].g_col[1].u_pe_n_0 ;
  wire \g_row[5].g_col[1].u_pe_n_1 ;
  wire \g_row[5].g_col[2].u_pe_n_0 ;
  wire \g_row[5].g_col[6].u_pe_n_32 ;
  wire \g_row[5].g_col[7].u_pe_n_32 ;
  wire [8:0]\g_row[6].g_col[0].a_in ;
  wire \g_row[6].g_col[0].u_pe_n_0 ;
  wire \g_row[6].g_col[0].u_pe_n_1 ;
  wire \g_row[6].g_col[0].u_pe_n_2 ;
  wire \g_row[6].g_col[0].u_pe_n_3 ;
  wire \g_row[6].g_col[0].u_pe_n_4 ;
  wire \g_row[6].g_col[0].u_pe_n_5 ;
  wire \g_row[6].g_col[0].u_pe_n_6 ;
  wire \g_row[6].g_col[0].u_pe_n_7 ;
  wire \g_row[6].g_col[0].u_pe_n_8 ;
  wire \g_row[6].g_col[4].u_pe_n_0 ;
  wire \g_row[6].g_col[5].u_pe_n_32 ;
  wire [8:0]\g_row[7].g_col[0].a_in ;
  wire \g_row[7].g_col[0].u_pe_n_0 ;
  wire \g_row[7].g_col[0].u_pe_n_1 ;
  wire \g_row[7].g_col[0].u_pe_n_2 ;
  wire \g_row[7].g_col[0].u_pe_n_3 ;
  wire \g_row[7].g_col[0].u_pe_n_4 ;
  wire \g_row[7].g_col[0].u_pe_n_5 ;
  wire \g_row[7].g_col[0].u_pe_n_6 ;
  wire \g_row[7].g_col[0].u_pe_n_7 ;
  wire \g_row[7].g_col[0].u_pe_n_8 ;
  wire \g_row[7].g_col[1].u_pe_n_0 ;
  wire \g_row[7].g_col[2].u_pe_n_0 ;
  wire \g_row[7].g_col[3].u_pe_n_0 ;
  wire \g_row[7].g_col[5].u_pe_n_32 ;
  wire \g_row[7].g_col[6].u_pe_n_32 ;
  wire \g_row[7].g_col[6].u_pe_n_33 ;
  wire [8:0]\g_skew_a[1].g_dn.sr ;
  wire \g_skew_a[2].g_dn.sr_reg_n_0_[0] ;
  wire \g_skew_a[2].g_dn.sr_reg_n_0_[1] ;
  wire \g_skew_a[2].g_dn.sr_reg_n_0_[2] ;
  wire \g_skew_a[2].g_dn.sr_reg_n_0_[3] ;
  wire \g_skew_a[2].g_dn.sr_reg_n_0_[4] ;
  wire \g_skew_a[2].g_dn.sr_reg_n_0_[5] ;
  wire \g_skew_a[2].g_dn.sr_reg_n_0_[6] ;
  wire \g_skew_a[2].g_dn.sr_reg_n_0_[7] ;
  wire \g_skew_a[2].g_dn.sr_reg_n_0_[8] ;
  wire \g_skew_a[3].g_dn.sr[0]_i_1_n_0 ;
  wire \g_skew_a[3].g_dn.sr[1]_i_1_n_0 ;
  wire \g_skew_a[3].g_dn.sr[2]_i_1_n_0 ;
  wire \g_skew_a[3].g_dn.sr[3]_i_1_n_0 ;
  wire \g_skew_a[3].g_dn.sr[4]_i_1_n_0 ;
  wire \g_skew_a[3].g_dn.sr[5]_i_1_n_0 ;
  wire \g_skew_a[3].g_dn.sr[6]_i_1_n_0 ;
  wire \g_skew_a[3].g_dn.sr[7]_i_1_n_0 ;
  wire \g_skew_a[3].g_dn.sr[8]_i_1_n_0 ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[0] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[10] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[11] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[12] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[13] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[14] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[15] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[16] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[17] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[1] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[2] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[3] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[4] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[5] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[6] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[7] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[8] ;
  wire \g_skew_a[3].g_dn.sr_reg_n_0_[9] ;
  wire \g_skew_a[4].g_dn.sr[0]_i_1_n_0 ;
  wire \g_skew_a[4].g_dn.sr[1]_i_1_n_0 ;
  wire \g_skew_a[4].g_dn.sr[2]_i_1_n_0 ;
  wire \g_skew_a[4].g_dn.sr[3]_i_1_n_0 ;
  wire \g_skew_a[4].g_dn.sr[4]_i_1_n_0 ;
  wire \g_skew_a[4].g_dn.sr[5]_i_1_n_0 ;
  wire \g_skew_a[4].g_dn.sr[6]_i_1_n_0 ;
  wire \g_skew_a[4].g_dn.sr[7]_i_1_n_0 ;
  wire \g_skew_a[4].g_dn.sr[8]_i_1_n_0 ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[0] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[10] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[11] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[12] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[13] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[14] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[15] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[16] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[17] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[18] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[19] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[1] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[20] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[21] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[22] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[23] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[24] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[25] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[26] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[2] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[3] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[4] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[5] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[6] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[7] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[8] ;
  wire \g_skew_a[4].g_dn.sr_reg_n_0_[9] ;
  wire \g_skew_a[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[16]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[16]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[17]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[17]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[18]_g_skew_b_r_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[19]_g_skew_b_r_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[20]_g_skew_b_r_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[21]_g_skew_b_r_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[22]_g_skew_b_r_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[23]_g_skew_b_r_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[24]_g_skew_b_r_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[25]_g_skew_b_r_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[26]_g_skew_b_r_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_a[5].g_dn.sr_reg_n_0_[27] ;
  wire \g_skew_a[5].g_dn.sr_reg_n_0_[28] ;
  wire \g_skew_a[5].g_dn.sr_reg_n_0_[29] ;
  wire \g_skew_a[5].g_dn.sr_reg_n_0_[30] ;
  wire \g_skew_a[5].g_dn.sr_reg_n_0_[31] ;
  wire \g_skew_a[5].g_dn.sr_reg_n_0_[32] ;
  wire \g_skew_a[5].g_dn.sr_reg_n_0_[33] ;
  wire \g_skew_a[5].g_dn.sr_reg_n_0_[34] ;
  wire \g_skew_a[5].g_dn.sr_reg_n_0_[35] ;
  wire \g_skew_a[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[24]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[24]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[25]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[25]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[26]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[26]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[27]_g_skew_b_r_2_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[28]_g_skew_b_r_2_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[29]_g_skew_b_r_2_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[30]_g_skew_b_r_2_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[31]_g_skew_b_r_2_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[32]_g_skew_b_r_2_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[33]_g_skew_b_r_2_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[34]_g_skew_b_r_2_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg[35]_g_skew_b_r_2_n_0 ;
  wire \g_skew_a[6].g_dn.sr_reg_n_0_[36] ;
  wire \g_skew_a[6].g_dn.sr_reg_n_0_[37] ;
  wire \g_skew_a[6].g_dn.sr_reg_n_0_[38] ;
  wire \g_skew_a[6].g_dn.sr_reg_n_0_[39] ;
  wire \g_skew_a[6].g_dn.sr_reg_n_0_[40] ;
  wire \g_skew_a[6].g_dn.sr_reg_n_0_[41] ;
  wire \g_skew_a[6].g_dn.sr_reg_n_0_[42] ;
  wire \g_skew_a[6].g_dn.sr_reg_n_0_[43] ;
  wire \g_skew_a[6].g_dn.sr_reg_n_0_[44] ;
  wire \g_skew_a[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[32]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[32]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[33]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[33]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[34]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[34]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[35]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[35]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[36]_g_skew_b_r_3_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[37]_g_skew_b_r_3_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[38]_g_skew_b_r_3_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[39]_g_skew_b_r_3_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[40]_g_skew_b_r_3_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[41]_g_skew_b_r_3_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[42]_g_skew_b_r_3_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[43]_g_skew_b_r_3_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg[44]_g_skew_b_r_3_n_0 ;
  wire \g_skew_a[7].g_dn.sr_reg_n_0_[45] ;
  wire \g_skew_a[7].g_dn.sr_reg_n_0_[46] ;
  wire \g_skew_a[7].g_dn.sr_reg_n_0_[47] ;
  wire \g_skew_a[7].g_dn.sr_reg_n_0_[48] ;
  wire \g_skew_a[7].g_dn.sr_reg_n_0_[49] ;
  wire \g_skew_a[7].g_dn.sr_reg_n_0_[50] ;
  wire \g_skew_a[7].g_dn.sr_reg_n_0_[51] ;
  wire \g_skew_a[7].g_dn.sr_reg_n_0_[52] ;
  wire \g_skew_a[7].g_dn.sr_reg_n_0_[53] ;
  wire [7:0]\g_skew_b[1].g_dn.sr ;
  wire \g_skew_b[2].g_dn.sr_reg_n_0_[0] ;
  wire \g_skew_b[2].g_dn.sr_reg_n_0_[1] ;
  wire \g_skew_b[2].g_dn.sr_reg_n_0_[2] ;
  wire \g_skew_b[2].g_dn.sr_reg_n_0_[3] ;
  wire \g_skew_b[2].g_dn.sr_reg_n_0_[4] ;
  wire \g_skew_b[2].g_dn.sr_reg_n_0_[5] ;
  wire \g_skew_b[2].g_dn.sr_reg_n_0_[6] ;
  wire \g_skew_b[2].g_dn.sr_reg_n_0_[7] ;
  wire \g_skew_b[3].g_dn.sr[0]_i_1_n_0 ;
  wire \g_skew_b[3].g_dn.sr[1]_i_1_n_0 ;
  wire \g_skew_b[3].g_dn.sr[2]_i_1_n_0 ;
  wire \g_skew_b[3].g_dn.sr[3]_i_1_n_0 ;
  wire \g_skew_b[3].g_dn.sr[4]_i_1_n_0 ;
  wire \g_skew_b[3].g_dn.sr[5]_i_1_n_0 ;
  wire \g_skew_b[3].g_dn.sr[6]_i_1_n_0 ;
  wire \g_skew_b[3].g_dn.sr[7]_i_1_n_0 ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[0] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[10] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[11] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[12] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[13] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[14] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[15] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[1] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[2] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[3] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[4] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[5] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[6] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[7] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[8] ;
  wire \g_skew_b[3].g_dn.sr_reg_n_0_[9] ;
  wire \g_skew_b[4].g_dn.sr[0]_i_1_n_0 ;
  wire \g_skew_b[4].g_dn.sr[1]_i_1_n_0 ;
  wire \g_skew_b[4].g_dn.sr[2]_i_1_n_0 ;
  wire \g_skew_b[4].g_dn.sr[3]_i_1_n_0 ;
  wire \g_skew_b[4].g_dn.sr[4]_i_1_n_0 ;
  wire \g_skew_b[4].g_dn.sr[5]_i_1_n_0 ;
  wire \g_skew_b[4].g_dn.sr[6]_i_1_n_0 ;
  wire \g_skew_b[4].g_dn.sr[7]_i_1_n_0 ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[0] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[10] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[11] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[12] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[13] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[14] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[15] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[16] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[17] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[18] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[19] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[1] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[20] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[21] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[22] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[23] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[2] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[3] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[4] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[5] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[6] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[7] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[8] ;
  wire \g_skew_b[4].g_dn.sr_reg_n_0_[9] ;
  wire \g_skew_b[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[16]_g_skew_b_r_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[17]_g_skew_b_r_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[18]_g_skew_b_r_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[19]_g_skew_b_r_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[20]_g_skew_b_r_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[21]_g_skew_b_r_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[22]_g_skew_b_r_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[23]_g_skew_b_r_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[8]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[8]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_i_1_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_n_0 ;
  wire \g_skew_b[5].g_dn.sr_reg_n_0_[24] ;
  wire \g_skew_b[5].g_dn.sr_reg_n_0_[25] ;
  wire \g_skew_b[5].g_dn.sr_reg_n_0_[26] ;
  wire \g_skew_b[5].g_dn.sr_reg_n_0_[27] ;
  wire \g_skew_b[5].g_dn.sr_reg_n_0_[28] ;
  wire \g_skew_b[5].g_dn.sr_reg_n_0_[29] ;
  wire \g_skew_b[5].g_dn.sr_reg_n_0_[30] ;
  wire \g_skew_b[5].g_dn.sr_reg_n_0_[31] ;
  wire \g_skew_b[6].g_dn.sr_reg[16]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[16]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[17]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[17]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_i_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[24]_g_skew_b_r_2_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[25]_g_skew_b_r_2_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[26]_g_skew_b_r_2_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[27]_g_skew_b_r_2_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[28]_g_skew_b_r_2_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[29]_g_skew_b_r_2_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[30]_g_skew_b_r_2_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg[31]_g_skew_b_r_2_n_0 ;
  wire \g_skew_b[6].g_dn.sr_reg_n_0_[32] ;
  wire \g_skew_b[6].g_dn.sr_reg_n_0_[33] ;
  wire \g_skew_b[6].g_dn.sr_reg_n_0_[34] ;
  wire \g_skew_b[6].g_dn.sr_reg_n_0_[35] ;
  wire \g_skew_b[6].g_dn.sr_reg_n_0_[36] ;
  wire \g_skew_b[6].g_dn.sr_reg_n_0_[37] ;
  wire \g_skew_b[6].g_dn.sr_reg_n_0_[38] ;
  wire \g_skew_b[6].g_dn.sr_reg_n_0_[39] ;
  wire \g_skew_b[7].g_dn.sr_reg[24]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[24]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[25]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[25]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[26]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[26]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_i_1_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[32]_g_skew_b_r_3_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[33]_g_skew_b_r_3_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[34]_g_skew_b_r_3_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[35]_g_skew_b_r_3_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[36]_g_skew_b_r_3_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[37]_g_skew_b_r_3_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[38]_g_skew_b_r_3_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg[39]_g_skew_b_r_3_n_0 ;
  wire \g_skew_b[7].g_dn.sr_reg_n_0_[40] ;
  wire \g_skew_b[7].g_dn.sr_reg_n_0_[41] ;
  wire \g_skew_b[7].g_dn.sr_reg_n_0_[42] ;
  wire \g_skew_b[7].g_dn.sr_reg_n_0_[43] ;
  wire \g_skew_b[7].g_dn.sr_reg_n_0_[44] ;
  wire \g_skew_b[7].g_dn.sr_reg_n_0_[45] ;
  wire \g_skew_b[7].g_dn.sr_reg_n_0_[46] ;
  wire \g_skew_b[7].g_dn.sr_reg_n_0_[47] ;
  wire g_skew_b_r_0_n_0;
  wire g_skew_b_r_1_n_0;
  wire g_skew_b_r_2_n_0;
  wire g_skew_b_r_3_n_0;
  wire g_skew_b_r_n_0;
  wire in_ok0;
  wire in_valid;
  wire [10:0]k_len;
  wire [10:0]k_reg;
  wire kcnt;
  wire \kcnt[0]_i_1_n_0 ;
  wire \kcnt[10]_i_3_n_0 ;
  wire \kcnt[5]_i_1_n_0 ;
  wire \kcnt[7]_i_1_n_0 ;
  wire \kcnt[8]_i_1_n_0 ;
  wire \kcnt[9]_i_2_n_0 ;
  wire [10:0]kcnt_reg;
  wire last_seen;
  wire last_seen0;
  wire last_seen_i_10_n_0;
  wire last_seen_i_11_n_0;
  wire last_seen_i_1_n_0;
  wire last_seen_i_3_n_0;
  wire last_seen_i_4_n_0;
  wire last_seen_i_5_n_0;
  wire last_seen_i_6_n_0;
  wire last_seen_i_7_n_0;
  wire last_seen_i_8_n_0;
  wire last_seen_i_9_n_0;
  wire last_seen_reg_i_2_n_1;
  wire last_seen_reg_i_2_n_2;
  wire last_seen_reg_i_2_n_3;
  wire [7:1]p_0_in;
  wire [10:1]p_0_in__0;
  wire pe_rst;
  wire rst;
  wire start;
  wire start_ok;
  wire \state[0]_i_1_n_0 ;
  wire \state[1]_i_1_n_0 ;
  wire \state_reg_n_0_[0] ;
  wire \state_reg_n_0_[1] ;
  wire [3:0]NLW_last_seen_reg_i_2_O_UNCONNECTED;

  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \dcnt[0]_i_1 
       (.I0(dcnt_reg[0]),
        .O(\dcnt[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \dcnt[1]_i_1 
       (.I0(dcnt_reg[1]),
        .I1(dcnt_reg[0]),
        .O(p_0_in[1]));
  LUT3 #(
    .INIT(8'h6A)) 
    \dcnt[2]_i_1 
       (.I0(dcnt_reg[2]),
        .I1(dcnt_reg[1]),
        .I2(dcnt_reg[0]),
        .O(p_0_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h6AAA)) 
    \dcnt[3]_i_1 
       (.I0(dcnt_reg[3]),
        .I1(dcnt_reg[0]),
        .I2(dcnt_reg[1]),
        .I3(dcnt_reg[2]),
        .O(p_0_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h6AAAAAAA)) 
    \dcnt[4]_i_1 
       (.I0(dcnt_reg[4]),
        .I1(dcnt_reg[2]),
        .I2(dcnt_reg[1]),
        .I3(dcnt_reg[0]),
        .I4(dcnt_reg[3]),
        .O(p_0_in[4]));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \dcnt[5]_i_1 
       (.I0(dcnt_reg[3]),
        .I1(dcnt_reg[0]),
        .I2(dcnt_reg[1]),
        .I3(dcnt_reg[2]),
        .I4(dcnt_reg[4]),
        .I5(dcnt_reg[5]),
        .O(p_0_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \dcnt[6]_i_1 
       (.I0(dcnt_reg[6]),
        .I1(\dcnt[7]_i_3_n_0 ),
        .O(p_0_in[6]));
  LUT4 #(
    .INIT(16'h0200)) 
    \dcnt[7]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(done_i_2_n_0),
        .I3(last_seen),
        .O(\dcnt[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \dcnt[7]_i_2 
       (.I0(dcnt_reg[7]),
        .I1(\dcnt[7]_i_3_n_0 ),
        .I2(dcnt_reg[6]),
        .O(p_0_in[7]));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \dcnt[7]_i_3 
       (.I0(dcnt_reg[5]),
        .I1(dcnt_reg[4]),
        .I2(dcnt_reg[2]),
        .I3(dcnt_reg[1]),
        .I4(dcnt_reg[0]),
        .I5(dcnt_reg[3]),
        .O(\dcnt[7]_i_3_n_0 ));
  FDRE \dcnt_reg[0] 
       (.C(clk),
        .CE(\dcnt[7]_i_1_n_0 ),
        .D(\dcnt[0]_i_1_n_0 ),
        .Q(dcnt_reg[0]),
        .R(pe_rst));
  FDRE \dcnt_reg[1] 
       (.C(clk),
        .CE(\dcnt[7]_i_1_n_0 ),
        .D(p_0_in[1]),
        .Q(dcnt_reg[1]),
        .R(pe_rst));
  FDRE \dcnt_reg[2] 
       (.C(clk),
        .CE(\dcnt[7]_i_1_n_0 ),
        .D(p_0_in[2]),
        .Q(dcnt_reg[2]),
        .R(pe_rst));
  FDRE \dcnt_reg[3] 
       (.C(clk),
        .CE(\dcnt[7]_i_1_n_0 ),
        .D(p_0_in[3]),
        .Q(dcnt_reg[3]),
        .R(pe_rst));
  FDRE \dcnt_reg[4] 
       (.C(clk),
        .CE(\dcnt[7]_i_1_n_0 ),
        .D(p_0_in[4]),
        .Q(dcnt_reg[4]),
        .R(pe_rst));
  FDRE \dcnt_reg[5] 
       (.C(clk),
        .CE(\dcnt[7]_i_1_n_0 ),
        .D(p_0_in[5]),
        .Q(dcnt_reg[5]),
        .R(pe_rst));
  FDRE \dcnt_reg[6] 
       (.C(clk),
        .CE(\dcnt[7]_i_1_n_0 ),
        .D(p_0_in[6]),
        .Q(dcnt_reg[6]),
        .R(pe_rst));
  FDRE \dcnt_reg[7] 
       (.C(clk),
        .CE(\dcnt[7]_i_1_n_0 ),
        .D(p_0_in[7]),
        .Q(dcnt_reg[7]),
        .R(pe_rst));
  LUT5 #(
    .INIT(32'hFFFF2000)) 
    done_i_1
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(done_i_2_n_0),
        .I3(last_seen),
        .I4(done),
        .O(done_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h00000008)) 
    done_i_2
       (.I0(dcnt_reg[0]),
        .I1(dcnt_reg[2]),
        .I2(dcnt_reg[5]),
        .I3(dcnt_reg[6]),
        .I4(done_i_3_n_0),
        .O(done_i_2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'hFFFD)) 
    done_i_3
       (.I0(dcnt_reg[3]),
        .I1(dcnt_reg[1]),
        .I2(dcnt_reg[7]),
        .I3(dcnt_reg[4]),
        .O(done_i_3_n_0));
  FDRE done_reg
       (.C(clk),
        .CE(1'b1),
        .D(done_i_1_n_0),
        .Q(done),
        .R(pe_rst));
  pe \g_row[0].g_col[0].u_pe 
       (.A({\g_row[0].g_col[0].u_pe_n_1 ,\g_row[0].g_col[0].a_in }),
        .CO(in_ok0),
        .E(busy),
        .Q(k_reg),
        .a_col(a_col[8:0]),
        .a_out(\a_w[0] ),
        .\a_out_reg[8]_0 (\state_reg_n_0_[0] ),
        .\a_out_reg[8]_1 (\state_reg_n_0_[1] ),
        .acc_reg_i_18_0(kcnt_reg),
        .b_in(\g_row[0].g_col[0].b_in ),
        .b_out(\b_w[0] ),
        .b_row(b_row[7:0]),
        .c_flat(c_flat[31:0]),
        .clk(clk),
        .en(\g_row[2].g_col[2].u_pe_n_1 ),
        .in_valid(in_valid),
        .last_seen(last_seen),
        .pe_rst(pe_rst));
  pe_0 \g_row[0].g_col[1].u_pe 
       (.A(\g_row[0].g_col[1].u_pe_n_1 ),
        .CO(in_ok0),
        .E(busy),
        .Q(\g_skew_b[1].g_dn.sr ),
        .a_col(a_col[8]),
        .a_in(\a_w[0] ),
        .a_out(\a_w[1] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[7].g_col[5].u_pe_n_32 ),
        .acc_reg_3({\g_row[0].g_col[0].u_pe_n_1 ,\g_row[0].g_col[0].a_in }),
        .b_in({\g_row[1].g_col[1].u_pe_n_1 ,\g_row[1].g_col[1].u_pe_n_2 ,\g_row[1].g_col[1].u_pe_n_3 ,\g_row[1].g_col[1].u_pe_n_4 ,\g_row[1].g_col[1].u_pe_n_5 ,\g_row[1].g_col[1].u_pe_n_6 ,\g_row[1].g_col[1].u_pe_n_7 ,\g_row[1].g_col[1].u_pe_n_8 }),
        .b_out(\b_w[1] ),
        .c_flat(c_flat[63:32]),
        .clk(clk),
        .en(\g_row[0].g_col[1].u_pe_n_0 ),
        .in_valid(in_valid),
        .last_seen(last_seen),
        .pe_rst(pe_rst));
  pe_1 \g_row[0].g_col[2].u_pe 
       (.A({\g_row[0].g_col[1].u_pe_n_1 ,\g_row[0].g_col[0].a_in }),
        .CO(in_ok0),
        .E(busy),
        .Q(\g_row[0].g_col[2].b_in ),
        .a_col(a_col[8]),
        .a_in(\a_w[1] ),
        .a_out(\a_w[2] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[7].g_col[6].u_pe_n_32 ),
        .acc_reg_3(\g_row[7].g_col[5].u_pe_n_32 ),
        .b_in({\g_row[0].g_col[2].u_pe_n_0 ,\g_row[0].g_col[2].u_pe_n_1 ,\g_row[0].g_col[2].u_pe_n_2 ,\g_row[0].g_col[2].u_pe_n_3 ,\g_row[0].g_col[2].u_pe_n_4 ,\g_row[0].g_col[2].u_pe_n_5 ,\g_row[0].g_col[2].u_pe_n_6 ,\g_row[0].g_col[2].u_pe_n_7 }),
        .b_out(\b_w[2] ),
        .b_row(b_row[23:16]),
        .c_flat(c_flat[95:64]),
        .clk(clk),
        .en(\g_row[2].g_col[2].u_pe_n_1 ),
        .in_valid(in_valid),
        .last_seen(last_seen),
        .pe_rst(pe_rst));
  pe_2 \g_row[0].g_col[3].u_pe 
       (.E(busy),
        .Q({\g_row[0].g_col[3].b_in ,\g_skew_b[3].g_dn.sr_reg_n_0_[7] ,\g_skew_b[3].g_dn.sr_reg_n_0_[6] ,\g_skew_b[3].g_dn.sr_reg_n_0_[5] ,\g_skew_b[3].g_dn.sr_reg_n_0_[4] ,\g_skew_b[3].g_dn.sr_reg_n_0_[3] ,\g_skew_b[3].g_dn.sr_reg_n_0_[2] ,\g_skew_b[3].g_dn.sr_reg_n_0_[1] ,\g_skew_b[3].g_dn.sr_reg_n_0_[0] }),
        .a_in(\a_w[2] ),
        .a_out(\a_w[3] ),
        .acc_reg_0(\g_row[7].g_col[6].u_pe_n_32 ),
        .acc_reg_1(\g_row[7].g_col[5].u_pe_n_32 ),
        .acc_reg_2(\a_w[0] ),
        .b_out(\b_w[3] ),
        .c_flat(c_flat[127:96]),
        .clk(clk),
        .en(\g_row[0].g_col[1].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_3 \g_row[0].g_col[4].u_pe 
       (.E(busy),
        .Q({\g_row[0].g_col[4].b_in ,\g_skew_b[4].g_dn.sr_reg_n_0_[15] ,\g_skew_b[4].g_dn.sr_reg_n_0_[14] ,\g_skew_b[4].g_dn.sr_reg_n_0_[13] ,\g_skew_b[4].g_dn.sr_reg_n_0_[12] ,\g_skew_b[4].g_dn.sr_reg_n_0_[11] ,\g_skew_b[4].g_dn.sr_reg_n_0_[10] ,\g_skew_b[4].g_dn.sr_reg_n_0_[9] ,\g_skew_b[4].g_dn.sr_reg_n_0_[8] }),
        .a_in(\a_w[3] ),
        .a_out(\a_w[4] ),
        .acc_reg_0(\g_row[7].g_col[6].u_pe_n_32 ),
        .acc_reg_1(\g_row[7].g_col[5].u_pe_n_32 ),
        .acc_reg_2(\a_w[1] ),
        .b_out(\b_w[4] ),
        .c_flat(c_flat[159:128]),
        .clk(clk),
        .en(\g_row[2].g_col[2].u_pe_n_1 ),
        .pe_rst(pe_rst));
  pe_4 \g_row[0].g_col[5].u_pe 
       (.E(busy),
        .Q(\g_row[0].g_col[5].b_in ),
        .a_in(\a_w[2] ),
        .acc_reg_0(\g_skew_b[5].g_dn.sr_reg[23]_g_skew_b_r_1_n_0 ),
        .acc_reg_1(g_skew_b_r_1_n_0),
        .acc_reg_10(\g_row[7].g_col[5].u_pe_n_32 ),
        .acc_reg_2(\g_skew_b[5].g_dn.sr_reg[22]_g_skew_b_r_1_n_0 ),
        .acc_reg_3(\g_skew_b[5].g_dn.sr_reg[21]_g_skew_b_r_1_n_0 ),
        .acc_reg_4(\g_skew_b[5].g_dn.sr_reg[20]_g_skew_b_r_1_n_0 ),
        .acc_reg_5(\g_skew_b[5].g_dn.sr_reg[19]_g_skew_b_r_1_n_0 ),
        .acc_reg_6(\g_skew_b[5].g_dn.sr_reg[18]_g_skew_b_r_1_n_0 ),
        .acc_reg_7(\g_skew_b[5].g_dn.sr_reg[17]_g_skew_b_r_1_n_0 ),
        .acc_reg_8(\g_skew_b[5].g_dn.sr_reg[16]_g_skew_b_r_1_n_0 ),
        .acc_reg_9(\g_row[7].g_col[6].u_pe_n_32 ),
        .b_in({\g_row[0].g_col[5].u_pe_n_0 ,\g_row[0].g_col[5].u_pe_n_1 ,\g_row[0].g_col[5].u_pe_n_2 ,\g_row[0].g_col[5].u_pe_n_3 ,\g_row[0].g_col[5].u_pe_n_4 ,\g_row[0].g_col[5].u_pe_n_5 ,\g_row[0].g_col[5].u_pe_n_6 ,\g_row[0].g_col[5].u_pe_n_7 }),
        .b_out(\b_w[5] ),
        .c_flat(c_flat[191:160]),
        .clk(clk),
        .en(\g_row[0].g_col[1].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_5 \g_row[0].g_col[6].u_pe 
       (.E(busy),
        .Q(\g_row[0].g_col[6].b_in ),
        .a_in(\a_w[3] ),
        .acc_reg_0(\g_skew_b[6].g_dn.sr_reg[31]_g_skew_b_r_2_n_0 ),
        .acc_reg_1(g_skew_b_r_2_n_0),
        .acc_reg_10(\g_row[7].g_col[5].u_pe_n_32 ),
        .acc_reg_2(\g_skew_b[6].g_dn.sr_reg[30]_g_skew_b_r_2_n_0 ),
        .acc_reg_3(\g_skew_b[6].g_dn.sr_reg[29]_g_skew_b_r_2_n_0 ),
        .acc_reg_4(\g_skew_b[6].g_dn.sr_reg[28]_g_skew_b_r_2_n_0 ),
        .acc_reg_5(\g_skew_b[6].g_dn.sr_reg[27]_g_skew_b_r_2_n_0 ),
        .acc_reg_6(\g_skew_b[6].g_dn.sr_reg[26]_g_skew_b_r_2_n_0 ),
        .acc_reg_7(\g_skew_b[6].g_dn.sr_reg[25]_g_skew_b_r_2_n_0 ),
        .acc_reg_8(\g_skew_b[6].g_dn.sr_reg[24]_g_skew_b_r_2_n_0 ),
        .acc_reg_9(\g_row[7].g_col[6].u_pe_n_32 ),
        .b_in({\g_row[0].g_col[6].u_pe_n_0 ,\g_row[0].g_col[6].u_pe_n_1 ,\g_row[0].g_col[6].u_pe_n_2 ,\g_row[0].g_col[6].u_pe_n_3 ,\g_row[0].g_col[6].u_pe_n_4 ,\g_row[0].g_col[6].u_pe_n_5 ,\g_row[0].g_col[6].u_pe_n_6 ,\g_row[0].g_col[6].u_pe_n_7 }),
        .b_out(\b_w[6] ),
        .c_flat(c_flat[223:192]),
        .clk(clk),
        .en(\g_row[2].g_col[2].u_pe_n_1 ),
        .pe_rst(pe_rst));
  pe_6 \g_row[0].g_col[7].u_pe 
       (.E(busy),
        .Q(\g_row[0].g_col[7].b_in ),
        .a_in(\a_w[4] ),
        .acc_reg_0(\g_skew_b[7].g_dn.sr_reg[39]_g_skew_b_r_3_n_0 ),
        .acc_reg_1(g_skew_b_r_3_n_0),
        .acc_reg_10(\g_row[7].g_col[5].u_pe_n_32 ),
        .acc_reg_2(\g_skew_b[7].g_dn.sr_reg[38]_g_skew_b_r_3_n_0 ),
        .acc_reg_3(\g_skew_b[7].g_dn.sr_reg[37]_g_skew_b_r_3_n_0 ),
        .acc_reg_4(\g_skew_b[7].g_dn.sr_reg[36]_g_skew_b_r_3_n_0 ),
        .acc_reg_5(\g_skew_b[7].g_dn.sr_reg[35]_g_skew_b_r_3_n_0 ),
        .acc_reg_6(\g_skew_b[7].g_dn.sr_reg[34]_g_skew_b_r_3_n_0 ),
        .acc_reg_7(\g_skew_b[7].g_dn.sr_reg[33]_g_skew_b_r_3_n_0 ),
        .acc_reg_8(\g_skew_b[7].g_dn.sr_reg[32]_g_skew_b_r_3_n_0 ),
        .acc_reg_9(\g_row[7].g_col[6].u_pe_n_32 ),
        .b_in({\g_row[0].g_col[7].u_pe_n_0 ,\g_row[0].g_col[7].u_pe_n_1 ,\g_row[0].g_col[7].u_pe_n_2 ,\g_row[0].g_col[7].u_pe_n_3 ,\g_row[0].g_col[7].u_pe_n_4 ,\g_row[0].g_col[7].u_pe_n_5 ,\g_row[0].g_col[7].u_pe_n_6 ,\g_row[0].g_col[7].u_pe_n_7 }),
        .b_out(\b_w[7] ),
        .c_flat(c_flat[255:224]),
        .clk(clk),
        .en(\g_row[0].g_col[1].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_7 \g_row[1].g_col[0].u_pe 
       (.E(busy),
        .Q(\g_skew_a[1].g_dn.sr ),
        .a_in({\g_row[1].g_col[1].u_pe_n_9 ,\g_row[1].g_col[1].u_pe_n_10 ,\g_row[1].g_col[1].u_pe_n_11 ,\g_row[1].g_col[1].u_pe_n_12 ,\g_row[1].g_col[1].u_pe_n_13 ,\g_row[1].g_col[1].u_pe_n_14 ,\g_row[1].g_col[1].u_pe_n_15 ,\g_row[1].g_col[1].u_pe_n_16 ,\g_row[1].g_col[1].u_pe_n_17 }),
        .a_out(\a_w[8] ),
        .acc_reg_0(\g_row[7].g_col[5].u_pe_n_32 ),
        .acc_reg_1(\g_row[0].g_col[0].b_in ),
        .b_in(\b_w[0] ),
        .b_out(\b_w[8] ),
        .c_flat(c_flat[287:256]),
        .clk(clk),
        .en(\g_row[2].g_col[2].u_pe_n_1 ),
        .pe_rst(pe_rst));
  pe_8 \g_row[1].g_col[1].u_pe 
       (.CO(in_ok0),
        .E(busy),
        .a_col(a_col[17:9]),
        .a_in({\g_row[1].g_col[1].u_pe_n_9 ,\g_row[1].g_col[1].u_pe_n_10 ,\g_row[1].g_col[1].u_pe_n_11 ,\g_row[1].g_col[1].u_pe_n_12 ,\g_row[1].g_col[1].u_pe_n_13 ,\g_row[1].g_col[1].u_pe_n_14 ,\g_row[1].g_col[1].u_pe_n_15 ,\g_row[1].g_col[1].u_pe_n_16 ,\g_row[1].g_col[1].u_pe_n_17 }),
        .a_out(\a_w[9] ),
        .\a_out_reg[8]_0 (\a_w[8] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .b_in({\g_row[1].g_col[1].u_pe_n_1 ,\g_row[1].g_col[1].u_pe_n_2 ,\g_row[1].g_col[1].u_pe_n_3 ,\g_row[1].g_col[1].u_pe_n_4 ,\g_row[1].g_col[1].u_pe_n_5 ,\g_row[1].g_col[1].u_pe_n_6 ,\g_row[1].g_col[1].u_pe_n_7 ,\g_row[1].g_col[1].u_pe_n_8 }),
        .b_out(\b_w[9] ),
        .\b_out_reg[7]_0 (\b_w[1] ),
        .b_row(b_row[15:8]),
        .c_flat(c_flat[319:288]),
        .clk(clk),
        .en(\g_row[0].g_col[1].u_pe_n_0 ),
        .in_valid(in_valid),
        .last_seen(last_seen),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[1].g_col[1].u_pe_n_0 ));
  pe_9 \g_row[1].g_col[2].u_pe 
       (.E(busy),
        .Q({\g_skew_b[2].g_dn.sr_reg_n_0_[7] ,\g_skew_b[2].g_dn.sr_reg_n_0_[6] ,\g_skew_b[2].g_dn.sr_reg_n_0_[5] ,\g_skew_b[2].g_dn.sr_reg_n_0_[4] ,\g_skew_b[2].g_dn.sr_reg_n_0_[3] ,\g_skew_b[2].g_dn.sr_reg_n_0_[2] ,\g_skew_b[2].g_dn.sr_reg_n_0_[1] ,\g_skew_b[2].g_dn.sr_reg_n_0_[0] }),
        .a_in(\a_w[9] ),
        .a_out(\a_w[10] ),
        .acc_reg_0(\g_row[2].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[1].g_col[1].u_pe_n_0 ),
        .acc_reg_2(\g_skew_a[1].g_dn.sr ),
        .b_in(\b_w[2] ),
        .b_out(\b_w[10] ),
        .c_flat(c_flat[351:320]),
        .clk(clk),
        .en(\g_row[2].g_col[2].u_pe_n_1 ),
        .pe_rst(pe_rst));
  pe_10 \g_row[1].g_col[3].u_pe 
       (.E(busy),
        .Q({\g_skew_b[3].g_dn.sr_reg_n_0_[15] ,\g_skew_b[3].g_dn.sr_reg_n_0_[14] ,\g_skew_b[3].g_dn.sr_reg_n_0_[13] ,\g_skew_b[3].g_dn.sr_reg_n_0_[12] ,\g_skew_b[3].g_dn.sr_reg_n_0_[11] ,\g_skew_b[3].g_dn.sr_reg_n_0_[10] ,\g_skew_b[3].g_dn.sr_reg_n_0_[9] ,\g_skew_b[3].g_dn.sr_reg_n_0_[8] }),
        .a_in(\a_w[10] ),
        .a_out(\a_w[11] ),
        .acc_reg_0(\g_row[2].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[1].g_col[1].u_pe_n_0 ),
        .acc_reg_2(\a_w[8] ),
        .b_in(\b_w[3] ),
        .b_out(\b_w[11] ),
        .c_flat(c_flat[383:352]),
        .clk(clk),
        .en(\g_row[0].g_col[1].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_11 \g_row[1].g_col[4].u_pe 
       (.E(busy),
        .Q({\g_skew_b[4].g_dn.sr_reg_n_0_[23] ,\g_skew_b[4].g_dn.sr_reg_n_0_[22] ,\g_skew_b[4].g_dn.sr_reg_n_0_[21] ,\g_skew_b[4].g_dn.sr_reg_n_0_[20] ,\g_skew_b[4].g_dn.sr_reg_n_0_[19] ,\g_skew_b[4].g_dn.sr_reg_n_0_[18] ,\g_skew_b[4].g_dn.sr_reg_n_0_[17] ,\g_skew_b[4].g_dn.sr_reg_n_0_[16] }),
        .a_in(\a_w[11] ),
        .a_out(\a_w[12] ),
        .acc_reg_0(\g_row[2].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[1].g_col[1].u_pe_n_0 ),
        .acc_reg_2(\a_w[9] ),
        .b_in(\b_w[4] ),
        .b_out(\b_w[12] ),
        .c_flat(c_flat[415:384]),
        .clk(clk),
        .en(\g_row[2].g_col[2].u_pe_n_1 ),
        .pe_rst(pe_rst));
  pe_12 \g_row[1].g_col[5].u_pe 
       (.E(busy),
        .a_in(\a_w[10] ),
        .acc_reg_0(\g_row[2].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[1].g_col[1].u_pe_n_0 ),
        .acc_reg_2({\g_skew_b[5].g_dn.sr_reg_n_0_[31] ,\g_skew_b[5].g_dn.sr_reg_n_0_[30] ,\g_skew_b[5].g_dn.sr_reg_n_0_[29] ,\g_skew_b[5].g_dn.sr_reg_n_0_[28] ,\g_skew_b[5].g_dn.sr_reg_n_0_[27] ,\g_skew_b[5].g_dn.sr_reg_n_0_[26] ,\g_skew_b[5].g_dn.sr_reg_n_0_[25] ,\g_skew_b[5].g_dn.sr_reg_n_0_[24] }),
        .b_in(\b_w[5] ),
        .b_out(\b_w[13] ),
        .c_flat(c_flat[447:416]),
        .clk(clk),
        .en(\g_row[0].g_col[1].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_13 \g_row[1].g_col[6].u_pe 
       (.E(busy),
        .a_in(\a_w[11] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[2].g_col[2].u_pe_n_0 ),
        .acc_reg_3({\g_skew_b[6].g_dn.sr_reg_n_0_[39] ,\g_skew_b[6].g_dn.sr_reg_n_0_[38] ,\g_skew_b[6].g_dn.sr_reg_n_0_[37] ,\g_skew_b[6].g_dn.sr_reg_n_0_[36] ,\g_skew_b[6].g_dn.sr_reg_n_0_[35] ,\g_skew_b[6].g_dn.sr_reg_n_0_[34] ,\g_skew_b[6].g_dn.sr_reg_n_0_[33] ,\g_skew_b[6].g_dn.sr_reg_n_0_[32] }),
        .b_in(\b_w[6] ),
        .b_out(\b_w[14] ),
        .c_flat(c_flat[479:448]),
        .clk(clk),
        .en(\g_row[2].g_col[2].u_pe_n_1 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[1].g_col[6].u_pe_n_0 ));
  pe_14 \g_row[1].g_col[7].u_pe 
       (.E(busy),
        .a_in(\a_w[12] ),
        .acc_reg_0(\g_row[2].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[1].g_col[6].u_pe_n_0 ),
        .acc_reg_2({\g_skew_b[7].g_dn.sr_reg_n_0_[47] ,\g_skew_b[7].g_dn.sr_reg_n_0_[46] ,\g_skew_b[7].g_dn.sr_reg_n_0_[45] ,\g_skew_b[7].g_dn.sr_reg_n_0_[44] ,\g_skew_b[7].g_dn.sr_reg_n_0_[43] ,\g_skew_b[7].g_dn.sr_reg_n_0_[42] ,\g_skew_b[7].g_dn.sr_reg_n_0_[41] ,\g_skew_b[7].g_dn.sr_reg_n_0_[40] }),
        .b_in(\b_w[7] ),
        .b_out(\b_w[15] ),
        .c_flat(c_flat[511:480]),
        .clk(clk),
        .en(\g_row[0].g_col[1].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_15 \g_row[2].g_col[0].u_pe 
       (.CO(in_ok0),
        .E(busy),
        .Q(\g_row[2].g_col[0].a_in ),
        .a_col(a_col[26:18]),
        .a_in({\g_row[2].g_col[0].u_pe_n_0 ,\g_row[2].g_col[0].u_pe_n_1 ,\g_row[2].g_col[0].u_pe_n_2 ,\g_row[2].g_col[0].u_pe_n_3 ,\g_row[2].g_col[0].u_pe_n_4 ,\g_row[2].g_col[0].u_pe_n_5 ,\g_row[2].g_col[0].u_pe_n_6 ,\g_row[2].g_col[0].u_pe_n_7 ,\g_row[2].g_col[0].u_pe_n_8 }),
        .a_out(\a_w[16] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[2].g_col[2].u_pe_n_0 ),
        .acc_reg_3(\g_row[1].g_col[6].u_pe_n_0 ),
        .acc_reg_4(\g_row[0].g_col[0].b_in ),
        .b_in(\b_w[8] ),
        .b_out(\b_w[16] ),
        .c_flat(c_flat[543:512]),
        .clk(clk),
        .en(\g_row[2].g_col[2].u_pe_n_1 ),
        .in_valid(in_valid),
        .last_seen(last_seen),
        .pe_rst(pe_rst));
  pe_16 \g_row[2].g_col[1].u_pe 
       (.E(busy),
        .Q(\g_skew_b[1].g_dn.sr ),
        .a_in(\a_w[16] ),
        .a_out(\a_w[17] ),
        .acc_reg_0(\g_row[1].g_col[6].u_pe_n_0 ),
        .acc_reg_1(\g_row[2].g_col[2].u_pe_n_0 ),
        .acc_reg_2({\g_skew_a[2].g_dn.sr_reg_n_0_[8] ,\g_skew_a[2].g_dn.sr_reg_n_0_[7] ,\g_skew_a[2].g_dn.sr_reg_n_0_[6] ,\g_skew_a[2].g_dn.sr_reg_n_0_[5] ,\g_skew_a[2].g_dn.sr_reg_n_0_[4] ,\g_skew_a[2].g_dn.sr_reg_n_0_[3] ,\g_skew_a[2].g_dn.sr_reg_n_0_[2] ,\g_skew_a[2].g_dn.sr_reg_n_0_[1] ,\g_skew_a[2].g_dn.sr_reg_n_0_[0] }),
        .b_in(\b_w[9] ),
        .b_out(\b_w[17] ),
        .c_flat(c_flat[575:544]),
        .clk(clk),
        .en(\g_row[0].g_col[1].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_17 \g_row[2].g_col[2].u_pe 
       (.E(busy),
        .Q(\g_row[0].g_col[2].b_in ),
        .a_in(\a_w[17] ),
        .a_out(\a_w[18] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[1].g_col[6].u_pe_n_0 ),
        .acc_reg_3(\g_row[2].g_col[0].a_in ),
        .b_in(\b_w[10] ),
        .b_out(\b_w[18] ),
        .c_flat(c_flat[607:576]),
        .clk(clk),
        .en(\g_row[2].g_col[2].u_pe_n_1 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[2].g_col[2].u_pe_n_0 ));
  pe_18 \g_row[2].g_col[3].u_pe 
       (.E(busy),
        .Q(\g_row[0].g_col[3].b_in ),
        .a_in(\a_w[18] ),
        .a_out(\a_w[19] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[1].g_col[6].u_pe_n_0 ),
        .acc_reg_3(\g_row[2].g_col[4].u_pe_n_0 ),
        .acc_reg_4(\a_w[16] ),
        .b_in(\b_w[11] ),
        .b_out(\b_w[19] ),
        .c_flat(c_flat[639:608]),
        .clk(clk),
        .en(\g_row[0].g_col[1].u_pe_n_0 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[2].g_col[3].u_pe_n_0 ));
  pe_19 \g_row[2].g_col[4].u_pe 
       (.E(busy),
        .Q(\g_row[0].g_col[4].b_in ),
        .a_in(\a_w[19] ),
        .a_out(\a_w[20] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[2].g_col[3].u_pe_n_0 ),
        .acc_reg_3(\a_w[17] ),
        .b_in(\b_w[12] ),
        .b_out(\b_w[20] ),
        .c_flat(c_flat[671:640]),
        .clk(clk),
        .en(\g_row[4].g_col[6].u_pe_n_0 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[2].g_col[4].u_pe_n_0 ));
  pe_20 \g_row[2].g_col[5].u_pe 
       (.E(busy),
        .Q(\g_row[0].g_col[5].b_in ),
        .a_in(\a_w[18] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[2].g_col[3].u_pe_n_0 ),
        .acc_reg_3(\g_row[2].g_col[4].u_pe_n_0 ),
        .b_in(\b_w[13] ),
        .b_out(\b_w[21] ),
        .c_flat(c_flat[703:672]),
        .clk(clk),
        .en(\g_row[2].g_col[5].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_21 \g_row[2].g_col[6].u_pe 
       (.E(busy),
        .Q(\g_row[0].g_col[6].b_in ),
        .a_in(\a_w[19] ),
        .acc_reg_0(\g_row[2].g_col[3].u_pe_n_0 ),
        .acc_reg_1(\g_row[2].g_col[4].u_pe_n_0 ),
        .b_in(\b_w[14] ),
        .b_out(\b_w[22] ),
        .c_flat(c_flat[735:704]),
        .clk(clk),
        .en(\g_row[4].g_col[6].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_22 \g_row[2].g_col[7].u_pe 
       (.E(busy),
        .Q(\g_row[0].g_col[7].b_in ),
        .a_in(\a_w[20] ),
        .acc_reg_0(\g_row[2].g_col[3].u_pe_n_0 ),
        .acc_reg_1(\g_row[2].g_col[4].u_pe_n_0 ),
        .b_in(\b_w[15] ),
        .b_out(\b_w[23] ),
        .c_flat(c_flat[767:736]),
        .clk(clk),
        .en(\g_row[2].g_col[5].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_23 \g_row[3].g_col[0].u_pe 
       (.E(busy),
        .Q({\g_row[3].g_col[0].a_in ,\g_skew_a[3].g_dn.sr_reg_n_0_[8] ,\g_skew_a[3].g_dn.sr_reg_n_0_[7] ,\g_skew_a[3].g_dn.sr_reg_n_0_[6] ,\g_skew_a[3].g_dn.sr_reg_n_0_[5] ,\g_skew_a[3].g_dn.sr_reg_n_0_[4] ,\g_skew_a[3].g_dn.sr_reg_n_0_[3] ,\g_skew_a[3].g_dn.sr_reg_n_0_[2] ,\g_skew_a[3].g_dn.sr_reg_n_0_[1] ,\g_skew_a[3].g_dn.sr_reg_n_0_[0] }),
        .a_out(\a_w[24] ),
        .acc_reg_0(\g_row[3].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[2].g_col[4].u_pe_n_0 ),
        .acc_reg_2(\b_w[0] ),
        .b_in(\b_w[16] ),
        .b_out(\b_w[24] ),
        .c_flat(c_flat[799:768]),
        .clk(clk),
        .en(\g_row[4].g_col[6].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_24 \g_row[3].g_col[1].u_pe 
       (.E(busy),
        .Q({\g_skew_a[3].g_dn.sr_reg_n_0_[17] ,\g_skew_a[3].g_dn.sr_reg_n_0_[16] ,\g_skew_a[3].g_dn.sr_reg_n_0_[15] ,\g_skew_a[3].g_dn.sr_reg_n_0_[14] ,\g_skew_a[3].g_dn.sr_reg_n_0_[13] ,\g_skew_a[3].g_dn.sr_reg_n_0_[12] ,\g_skew_a[3].g_dn.sr_reg_n_0_[11] ,\g_skew_a[3].g_dn.sr_reg_n_0_[10] ,\g_skew_a[3].g_dn.sr_reg_n_0_[9] }),
        .a_in(\a_w[24] ),
        .a_out(\a_w[25] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[3].g_col[2].u_pe_n_0 ),
        .acc_reg_3(\b_w[1] ),
        .b_in(\b_w[17] ),
        .b_out(\b_w[25] ),
        .c_flat(c_flat[831:800]),
        .clk(clk),
        .en(\g_row[2].g_col[5].u_pe_n_0 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[3].g_col[1].u_pe_n_0 ));
  pe_25 \g_row[3].g_col[2].u_pe 
       (.E(busy),
        .Q(\g_row[3].g_col[0].a_in ),
        .a_in(\a_w[25] ),
        .a_out(\a_w[26] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[3].g_col[1].u_pe_n_0 ),
        .acc_reg_3(\b_w[2] ),
        .b_in(\b_w[18] ),
        .b_out(\b_w[26] ),
        .c_flat(c_flat[863:832]),
        .clk(clk),
        .en(\g_row[4].g_col[6].u_pe_n_0 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[3].g_col[2].u_pe_n_0 ));
  pe_26 \g_row[3].g_col[3].u_pe 
       (.E(busy),
        .a_in(\a_w[26] ),
        .a_out(\a_w[27] ),
        .acc_reg_0(\g_row[3].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[3].g_col[1].u_pe_n_0 ),
        .acc_reg_2(\b_w[3] ),
        .acc_reg_3(\a_w[24] ),
        .b_in(\b_w[19] ),
        .b_out(\b_w[27] ),
        .c_flat(c_flat[895:864]),
        .clk(clk),
        .en(\g_row[2].g_col[5].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_27 \g_row[3].g_col[4].u_pe 
       (.E(busy),
        .a_in(\a_w[27] ),
        .a_out(\a_w[28] ),
        .acc_reg_0(\g_row[3].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[3].g_col[1].u_pe_n_0 ),
        .acc_reg_2(\b_w[4] ),
        .acc_reg_3(\a_w[25] ),
        .b_in(\b_w[20] ),
        .b_out(\b_w[28] ),
        .c_flat(c_flat[927:896]),
        .clk(clk),
        .en(\g_row[4].g_col[6].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_28 \g_row[3].g_col[5].u_pe 
       (.E(busy),
        .a_in(\a_w[26] ),
        .acc_reg_0(\g_row[3].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[3].g_col[1].u_pe_n_0 ),
        .b_in(\b_w[5] ),
        .b_out(\b_w[29] ),
        .\b_out_reg[7]_0 (\b_w[21] ),
        .c_flat(c_flat[959:928]),
        .clk(clk),
        .en(\g_row[2].g_col[5].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_29 \g_row[3].g_col[6].u_pe 
       (.E(busy),
        .a_in(\a_w[27] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .b_in(\b_w[6] ),
        .b_out(\b_w[30] ),
        .\b_out_reg[7]_0 (\b_w[22] ),
        .c_flat(c_flat[991:960]),
        .clk(clk),
        .en(\g_row[4].g_col[6].u_pe_n_0 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[3].g_col[6].u_pe_n_0 ),
        .\state_reg[0]_0 (\g_row[3].g_col[6].u_pe_n_1 ));
  pe_30 \g_row[3].g_col[7].u_pe 
       (.E(busy),
        .a_in(\a_w[28] ),
        .acc_reg_0(\g_row[3].g_col[6].u_pe_n_0 ),
        .acc_reg_1(\g_row[3].g_col[6].u_pe_n_1 ),
        .b_in(\b_w[7] ),
        .b_out(\b_w[31] ),
        .\b_out_reg[7]_0 (\b_w[23] ),
        .c_flat(c_flat[1023:992]),
        .clk(clk),
        .en(\g_row[2].g_col[5].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_31 \g_row[4].g_col[0].u_pe 
       (.E(busy),
        .Q({\g_row[4].g_col[0].a_in ,\g_skew_a[4].g_dn.sr_reg_n_0_[17] ,\g_skew_a[4].g_dn.sr_reg_n_0_[16] ,\g_skew_a[4].g_dn.sr_reg_n_0_[15] ,\g_skew_a[4].g_dn.sr_reg_n_0_[14] ,\g_skew_a[4].g_dn.sr_reg_n_0_[13] ,\g_skew_a[4].g_dn.sr_reg_n_0_[12] ,\g_skew_a[4].g_dn.sr_reg_n_0_[11] ,\g_skew_a[4].g_dn.sr_reg_n_0_[10] ,\g_skew_a[4].g_dn.sr_reg_n_0_[9] }),
        .a_out(\a_w[32] ),
        .acc_reg_0(\g_row[3].g_col[6].u_pe_n_0 ),
        .acc_reg_1(\g_row[3].g_col[6].u_pe_n_1 ),
        .acc_reg_2(\b_w[8] ),
        .b_in(\b_w[24] ),
        .b_out(\b_w[32] ),
        .c_flat(c_flat[1055:1024]),
        .clk(clk),
        .en(\g_row[4].g_col[6].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_32 \g_row[4].g_col[1].u_pe 
       (.E(busy),
        .Q({\g_skew_a[4].g_dn.sr_reg_n_0_[26] ,\g_skew_a[4].g_dn.sr_reg_n_0_[25] ,\g_skew_a[4].g_dn.sr_reg_n_0_[24] ,\g_skew_a[4].g_dn.sr_reg_n_0_[23] ,\g_skew_a[4].g_dn.sr_reg_n_0_[22] ,\g_skew_a[4].g_dn.sr_reg_n_0_[21] ,\g_skew_a[4].g_dn.sr_reg_n_0_[20] ,\g_skew_a[4].g_dn.sr_reg_n_0_[19] ,\g_skew_a[4].g_dn.sr_reg_n_0_[18] }),
        .a_in(\a_w[32] ),
        .a_out(\a_w[33] ),
        .acc_reg_0(\g_row[3].g_col[6].u_pe_n_1 ),
        .acc_reg_1(\g_row[3].g_col[6].u_pe_n_0 ),
        .acc_reg_2(\b_w[9] ),
        .b_in(\b_w[25] ),
        .b_out(\b_w[33] ),
        .c_flat(c_flat[1087:1056]),
        .clk(clk),
        .en(\g_row[2].g_col[5].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_33 \g_row[4].g_col[2].u_pe 
       (.E(busy),
        .Q(\g_row[4].g_col[0].a_in ),
        .a_in(\a_w[33] ),
        .a_out(\a_w[34] ),
        .acc_reg_0(\g_row[3].g_col[6].u_pe_n_0 ),
        .acc_reg_1(\g_row[3].g_col[6].u_pe_n_1 ),
        .acc_reg_2(\b_w[10] ),
        .b_in(\b_w[26] ),
        .b_out(\b_w[34] ),
        .c_flat(c_flat[1119:1088]),
        .clk(clk),
        .en(\g_row[4].g_col[6].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_34 \g_row[4].g_col[3].u_pe 
       (.E(busy),
        .a_in(\a_w[34] ),
        .a_out(\a_w[35] ),
        .acc_reg_0(\g_row[3].g_col[6].u_pe_n_0 ),
        .acc_reg_1(\g_row[3].g_col[6].u_pe_n_1 ),
        .acc_reg_2(\g_row[4].g_col[4].u_pe_n_1 ),
        .acc_reg_3(\b_w[11] ),
        .acc_reg_4(\a_w[32] ),
        .b_in(\b_w[27] ),
        .b_out(\b_w[35] ),
        .\b_out_reg[0]_0 (\state_reg_n_0_[0] ),
        .\b_out_reg[0]_1 (\state_reg_n_0_[1] ),
        .c_flat(c_flat[1151:1120]),
        .clk(clk),
        .en(\g_row[2].g_col[5].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_35 \g_row[4].g_col[4].u_pe 
       (.E(busy),
        .a_in(\a_w[35] ),
        .a_out(\a_w[36] ),
        .acc_reg_0(\b_w[12] ),
        .acc_reg_1(\a_w[33] ),
        .b_in(\b_w[28] ),
        .b_out(\b_w[36] ),
        .\b_out_reg[0]_0 (\state_reg_n_0_[0] ),
        .\b_out_reg[0]_1 (\state_reg_n_0_[1] ),
        .c_flat(c_flat[1183:1152]),
        .clk(clk),
        .en(\g_row[4].g_col[6].u_pe_n_0 ),
        .pe_rst(pe_rst),
        .rst(rst),
        .start(start),
        .\state_reg[0] (\g_row[4].g_col[4].u_pe_n_0 ),
        .\state_reg[0]_0 (\g_row[4].g_col[4].u_pe_n_1 ));
  pe_36 \g_row[4].g_col[5].u_pe 
       (.E(busy),
        .a_in(\a_w[34] ),
        .acc_reg_0(\g_row[4].g_col[4].u_pe_n_0 ),
        .acc_reg_1(\g_row[4].g_col[4].u_pe_n_1 ),
        .b_in(\b_w[13] ),
        .b_out(\b_w[37] ),
        .\b_out_reg[7]_0 (\b_w[29] ),
        .c_flat(c_flat[1215:1184]),
        .clk(clk),
        .en(\g_row[2].g_col[5].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_37 \g_row[4].g_col[6].u_pe 
       (.E(busy),
        .a_in(\a_w[35] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[4].g_col[4].u_pe_n_0 ),
        .acc_reg_3(\g_row[4].g_col[4].u_pe_n_1 ),
        .b_in(\b_w[14] ),
        .b_out(\b_w[38] ),
        .\b_out_reg[7]_0 (\b_w[30] ),
        .c_flat(c_flat[1247:1216]),
        .clk(clk),
        .en(\g_row[4].g_col[6].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_38 \g_row[4].g_col[7].u_pe 
       (.E(busy),
        .a_in(\a_w[36] ),
        .acc_reg_0(\g_row[4].g_col[4].u_pe_n_0 ),
        .acc_reg_1(\g_row[4].g_col[4].u_pe_n_1 ),
        .b_in(\b_w[15] ),
        .b_out(\b_w[39] ),
        .\b_out_reg[7]_0 (\b_w[31] ),
        .c_flat(c_flat[1279:1248]),
        .clk(clk),
        .en(\g_row[2].g_col[5].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_39 \g_row[5].g_col[0].u_pe 
       (.E(busy),
        .Q(\g_row[5].g_col[0].a_in ),
        .a_in({\g_row[5].g_col[0].u_pe_n_0 ,\g_row[5].g_col[0].u_pe_n_1 ,\g_row[5].g_col[0].u_pe_n_2 ,\g_row[5].g_col[0].u_pe_n_3 ,\g_row[5].g_col[0].u_pe_n_4 ,\g_row[5].g_col[0].u_pe_n_5 ,\g_row[5].g_col[0].u_pe_n_6 ,\g_row[5].g_col[0].u_pe_n_7 ,\g_row[5].g_col[0].u_pe_n_8 }),
        .a_out(\a_w[40] ),
        .acc_reg_0(\g_skew_a[5].g_dn.sr_reg[26]_g_skew_b_r_1_n_0 ),
        .acc_reg_1(g_skew_b_r_1_n_0),
        .acc_reg_10(\g_row[4].g_col[4].u_pe_n_0 ),
        .acc_reg_11(\g_row[4].g_col[4].u_pe_n_1 ),
        .acc_reg_2(\g_skew_a[5].g_dn.sr_reg[25]_g_skew_b_r_1_n_0 ),
        .acc_reg_3(\g_skew_a[5].g_dn.sr_reg[24]_g_skew_b_r_1_n_0 ),
        .acc_reg_4(\g_skew_a[5].g_dn.sr_reg[23]_g_skew_b_r_1_n_0 ),
        .acc_reg_5(\g_skew_a[5].g_dn.sr_reg[22]_g_skew_b_r_1_n_0 ),
        .acc_reg_6(\g_skew_a[5].g_dn.sr_reg[21]_g_skew_b_r_1_n_0 ),
        .acc_reg_7(\g_skew_a[5].g_dn.sr_reg[20]_g_skew_b_r_1_n_0 ),
        .acc_reg_8(\g_skew_a[5].g_dn.sr_reg[19]_g_skew_b_r_1_n_0 ),
        .acc_reg_9(\g_skew_a[5].g_dn.sr_reg[18]_g_skew_b_r_1_n_0 ),
        .b_in(\b_w[16] ),
        .c_flat(c_flat[1311:1280]),
        .clk(clk),
        .en(\g_row[7].g_col[2].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_40 \g_row[5].g_col[1].u_pe 
       (.E(busy),
        .a_in(\a_w[40] ),
        .a_out(\a_w[41] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[4].g_col[4].u_pe_n_0 ),
        .acc_reg_3({\g_skew_a[5].g_dn.sr_reg_n_0_[35] ,\g_skew_a[5].g_dn.sr_reg_n_0_[34] ,\g_skew_a[5].g_dn.sr_reg_n_0_[33] ,\g_skew_a[5].g_dn.sr_reg_n_0_[32] ,\g_skew_a[5].g_dn.sr_reg_n_0_[31] ,\g_skew_a[5].g_dn.sr_reg_n_0_[30] ,\g_skew_a[5].g_dn.sr_reg_n_0_[29] ,\g_skew_a[5].g_dn.sr_reg_n_0_[28] ,\g_skew_a[5].g_dn.sr_reg_n_0_[27] }),
        .b_in(\b_w[17] ),
        .c_flat(c_flat[1343:1312]),
        .clk(clk),
        .en(\g_row[5].g_col[1].u_pe_n_1 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[5].g_col[1].u_pe_n_0 ));
  pe_41 \g_row[5].g_col[2].u_pe 
       (.E(busy),
        .Q(\g_row[5].g_col[0].a_in ),
        .a_in(\a_w[41] ),
        .a_out(\a_w[42] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[5].g_col[1].u_pe_n_0 ),
        .b_in(\b_w[18] ),
        .c_flat(c_flat[1375:1344]),
        .clk(clk),
        .en(\g_row[7].g_col[2].u_pe_n_0 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[5].g_col[2].u_pe_n_0 ));
  pe_42 \g_row[5].g_col[3].u_pe 
       (.E(busy),
        .a_in(\a_w[40] ),
        .a_out(\a_w[43] ),
        .\a_out_reg[8]_0 (\a_w[42] ),
        .acc_reg_0(\g_row[5].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[5].g_col[1].u_pe_n_0 ),
        .b_in(\b_w[19] ),
        .c_flat(c_flat[1407:1376]),
        .clk(clk),
        .en(\g_row[5].g_col[1].u_pe_n_1 ),
        .pe_rst(pe_rst));
  pe_43 \g_row[5].g_col[4].u_pe 
       (.E(busy),
        .a_in(\a_w[41] ),
        .a_out(\a_w[44] ),
        .\a_out_reg[8]_0 (\a_w[43] ),
        .acc_reg_0(\g_row[5].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[5].g_col[1].u_pe_n_0 ),
        .b_in(\b_w[20] ),
        .c_flat(c_flat[1439:1408]),
        .clk(clk),
        .en(\g_row[7].g_col[2].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_44 \g_row[5].g_col[5].u_pe 
       (.a_out(\a_w[42] ),
        .acc_reg_0(\g_row[5].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\g_row[5].g_col[1].u_pe_n_0 ),
        .b_out(\b_w[21] ),
        .c_flat(c_flat[1471:1440]),
        .clk(clk),
        .en(\g_row[5].g_col[1].u_pe_n_1 ),
        .pe_rst(pe_rst));
  pe_45 \g_row[5].g_col[6].u_pe 
       (.a_out(\a_w[43] ),
        .acc_reg_0(\g_row[5].g_col[2].u_pe_n_0 ),
        .acc_reg_1(\state_reg_n_0_[0] ),
        .acc_reg_2(\state_reg_n_0_[1] ),
        .b_out(\b_w[22] ),
        .c_flat(c_flat[1503:1472]),
        .clk(clk),
        .en(\g_row[7].g_col[2].u_pe_n_0 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[5].g_col[6].u_pe_n_32 ));
  pe_46 \g_row[5].g_col[7].u_pe 
       (.a_out(\a_w[44] ),
        .acc_reg_0(\g_row[5].g_col[6].u_pe_n_32 ),
        .acc_reg_1(\state_reg_n_0_[0] ),
        .acc_reg_2(\state_reg_n_0_[1] ),
        .b_out(\b_w[23] ),
        .c_flat(c_flat[1535:1504]),
        .clk(clk),
        .en(\g_row[5].g_col[1].u_pe_n_1 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[5].g_col[7].u_pe_n_32 ));
  pe_47 \g_row[6].g_col[0].u_pe 
       (.E(busy),
        .Q(\g_row[6].g_col[0].a_in ),
        .a_in({\g_row[6].g_col[0].u_pe_n_0 ,\g_row[6].g_col[0].u_pe_n_1 ,\g_row[6].g_col[0].u_pe_n_2 ,\g_row[6].g_col[0].u_pe_n_3 ,\g_row[6].g_col[0].u_pe_n_4 ,\g_row[6].g_col[0].u_pe_n_5 ,\g_row[6].g_col[0].u_pe_n_6 ,\g_row[6].g_col[0].u_pe_n_7 ,\g_row[6].g_col[0].u_pe_n_8 }),
        .a_out(\a_w[48] ),
        .acc_reg_0(\g_skew_a[6].g_dn.sr_reg[35]_g_skew_b_r_2_n_0 ),
        .acc_reg_1(g_skew_b_r_2_n_0),
        .acc_reg_10(\g_row[5].g_col[7].u_pe_n_32 ),
        .acc_reg_11(\g_row[5].g_col[6].u_pe_n_32 ),
        .acc_reg_2(\g_skew_a[6].g_dn.sr_reg[34]_g_skew_b_r_2_n_0 ),
        .acc_reg_3(\g_skew_a[6].g_dn.sr_reg[33]_g_skew_b_r_2_n_0 ),
        .acc_reg_4(\g_skew_a[6].g_dn.sr_reg[32]_g_skew_b_r_2_n_0 ),
        .acc_reg_5(\g_skew_a[6].g_dn.sr_reg[31]_g_skew_b_r_2_n_0 ),
        .acc_reg_6(\g_skew_a[6].g_dn.sr_reg[30]_g_skew_b_r_2_n_0 ),
        .acc_reg_7(\g_skew_a[6].g_dn.sr_reg[29]_g_skew_b_r_2_n_0 ),
        .acc_reg_8(\g_skew_a[6].g_dn.sr_reg[28]_g_skew_b_r_2_n_0 ),
        .acc_reg_9(\g_skew_a[6].g_dn.sr_reg[27]_g_skew_b_r_2_n_0 ),
        .b_in(\b_w[24] ),
        .c_flat(c_flat[1567:1536]),
        .clk(clk),
        .en(\g_row[7].g_col[2].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_48 \g_row[6].g_col[1].u_pe 
       (.E(busy),
        .a_in(\a_w[48] ),
        .a_out(\a_w[49] ),
        .acc_reg_0(\g_row[5].g_col[6].u_pe_n_32 ),
        .acc_reg_1(\g_row[5].g_col[7].u_pe_n_32 ),
        .acc_reg_2({\g_skew_a[6].g_dn.sr_reg_n_0_[44] ,\g_skew_a[6].g_dn.sr_reg_n_0_[43] ,\g_skew_a[6].g_dn.sr_reg_n_0_[42] ,\g_skew_a[6].g_dn.sr_reg_n_0_[41] ,\g_skew_a[6].g_dn.sr_reg_n_0_[40] ,\g_skew_a[6].g_dn.sr_reg_n_0_[39] ,\g_skew_a[6].g_dn.sr_reg_n_0_[38] ,\g_skew_a[6].g_dn.sr_reg_n_0_[37] ,\g_skew_a[6].g_dn.sr_reg_n_0_[36] }),
        .b_in(\b_w[25] ),
        .c_flat(c_flat[1599:1568]),
        .clk(clk),
        .en(\g_row[5].g_col[1].u_pe_n_1 ),
        .pe_rst(pe_rst));
  pe_49 \g_row[6].g_col[2].u_pe 
       (.E(busy),
        .Q(\g_row[6].g_col[0].a_in ),
        .a_in(\a_w[49] ),
        .a_out(\a_w[50] ),
        .acc_reg_0(\g_row[5].g_col[7].u_pe_n_32 ),
        .acc_reg_1(\g_row[5].g_col[6].u_pe_n_32 ),
        .b_in(\b_w[26] ),
        .c_flat(c_flat[1631:1600]),
        .clk(clk),
        .en(\g_row[7].g_col[2].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_50 \g_row[6].g_col[3].u_pe 
       (.E(busy),
        .a_in(\a_w[48] ),
        .a_out(\a_w[51] ),
        .\a_out_reg[8]_0 (\a_w[50] ),
        .acc_reg_0(\g_row[5].g_col[7].u_pe_n_32 ),
        .acc_reg_1(\g_row[5].g_col[6].u_pe_n_32 ),
        .acc_reg_2(\g_row[6].g_col[4].u_pe_n_0 ),
        .b_in(\b_w[27] ),
        .c_flat(c_flat[1663:1632]),
        .clk(clk),
        .en(\g_row[5].g_col[1].u_pe_n_1 ),
        .pe_rst(pe_rst));
  pe_51 \g_row[6].g_col[4].u_pe 
       (.E(busy),
        .a_in(\a_w[49] ),
        .a_out(\a_w[52] ),
        .\a_out_reg[8]_0 (\a_w[51] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[5].g_col[7].u_pe_n_32 ),
        .b_in(\b_w[28] ),
        .c_flat(c_flat[1695:1664]),
        .clk(clk),
        .en(\g_row[7].g_col[2].u_pe_n_0 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[6].g_col[4].u_pe_n_0 ));
  pe_52 \g_row[6].g_col[5].u_pe 
       (.a_out(\a_w[50] ),
        .acc_reg_0(\g_row[6].g_col[4].u_pe_n_0 ),
        .acc_reg_1(\state_reg_n_0_[0] ),
        .acc_reg_2(\state_reg_n_0_[1] ),
        .b_out(\b_w[29] ),
        .c_flat(c_flat[1727:1696]),
        .clk(clk),
        .en(\g_row[5].g_col[1].u_pe_n_1 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[6].g_col[5].u_pe_n_32 ));
  pe_53 \g_row[6].g_col[6].u_pe 
       (.a_out(\a_w[51] ),
        .acc_reg_0(\g_row[6].g_col[5].u_pe_n_32 ),
        .acc_reg_1(\g_row[6].g_col[4].u_pe_n_0 ),
        .b_out(\b_w[30] ),
        .c_flat(c_flat[1759:1728]),
        .clk(clk),
        .en(\g_row[7].g_col[2].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_54 \g_row[6].g_col[7].u_pe 
       (.a_out(\a_w[52] ),
        .acc_reg_0(\g_row[6].g_col[5].u_pe_n_32 ),
        .acc_reg_1(\g_row[6].g_col[4].u_pe_n_0 ),
        .b_out(\b_w[31] ),
        .c_flat(c_flat[1791:1760]),
        .clk(clk),
        .en(\g_row[5].g_col[1].u_pe_n_1 ),
        .pe_rst(pe_rst));
  pe_55 \g_row[7].g_col[0].u_pe 
       (.E(busy),
        .Q(\g_row[7].g_col[0].a_in ),
        .a_in({\g_row[7].g_col[0].u_pe_n_0 ,\g_row[7].g_col[0].u_pe_n_1 ,\g_row[7].g_col[0].u_pe_n_2 ,\g_row[7].g_col[0].u_pe_n_3 ,\g_row[7].g_col[0].u_pe_n_4 ,\g_row[7].g_col[0].u_pe_n_5 ,\g_row[7].g_col[0].u_pe_n_6 ,\g_row[7].g_col[0].u_pe_n_7 ,\g_row[7].g_col[0].u_pe_n_8 }),
        .a_out(\a_w[56] ),
        .acc_reg_0(\g_skew_a[7].g_dn.sr_reg[44]_g_skew_b_r_3_n_0 ),
        .acc_reg_1(g_skew_b_r_3_n_0),
        .acc_reg_10(\g_row[6].g_col[5].u_pe_n_32 ),
        .acc_reg_11(\g_row[6].g_col[4].u_pe_n_0 ),
        .acc_reg_2(\g_skew_a[7].g_dn.sr_reg[43]_g_skew_b_r_3_n_0 ),
        .acc_reg_3(\g_skew_a[7].g_dn.sr_reg[42]_g_skew_b_r_3_n_0 ),
        .acc_reg_4(\g_skew_a[7].g_dn.sr_reg[41]_g_skew_b_r_3_n_0 ),
        .acc_reg_5(\g_skew_a[7].g_dn.sr_reg[40]_g_skew_b_r_3_n_0 ),
        .acc_reg_6(\g_skew_a[7].g_dn.sr_reg[39]_g_skew_b_r_3_n_0 ),
        .acc_reg_7(\g_skew_a[7].g_dn.sr_reg[38]_g_skew_b_r_3_n_0 ),
        .acc_reg_8(\g_skew_a[7].g_dn.sr_reg[37]_g_skew_b_r_3_n_0 ),
        .acc_reg_9(\g_skew_a[7].g_dn.sr_reg[36]_g_skew_b_r_3_n_0 ),
        .b_in(\b_w[32] ),
        .c_flat(c_flat[1823:1792]),
        .clk(clk),
        .en(\g_row[7].g_col[2].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_56 \g_row[7].g_col[1].u_pe 
       (.E(busy),
        .a_in(\a_w[56] ),
        .a_out(\a_w[57] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[6].g_col[5].u_pe_n_32 ),
        .acc_reg_3({\g_skew_a[7].g_dn.sr_reg_n_0_[53] ,\g_skew_a[7].g_dn.sr_reg_n_0_[52] ,\g_skew_a[7].g_dn.sr_reg_n_0_[51] ,\g_skew_a[7].g_dn.sr_reg_n_0_[50] ,\g_skew_a[7].g_dn.sr_reg_n_0_[49] ,\g_skew_a[7].g_dn.sr_reg_n_0_[48] ,\g_skew_a[7].g_dn.sr_reg_n_0_[47] ,\g_skew_a[7].g_dn.sr_reg_n_0_[46] ,\g_skew_a[7].g_dn.sr_reg_n_0_[45] }),
        .b_in(\b_w[33] ),
        .c_flat(c_flat[1855:1824]),
        .clk(clk),
        .en(\g_row[5].g_col[1].u_pe_n_1 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[7].g_col[1].u_pe_n_0 ));
  pe_57 \g_row[7].g_col[2].u_pe 
       (.E(busy),
        .Q(\g_row[7].g_col[0].a_in ),
        .a_in(\a_w[57] ),
        .a_out(\a_w[58] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[6].g_col[5].u_pe_n_32 ),
        .acc_reg_3(\g_row[7].g_col[1].u_pe_n_0 ),
        .b_in(\b_w[34] ),
        .c_flat(c_flat[1887:1856]),
        .clk(clk),
        .en(\g_row[7].g_col[2].u_pe_n_0 ),
        .pe_rst(pe_rst));
  pe_58 \g_row[7].g_col[3].u_pe 
       (.E(busy),
        .a_in(\a_w[56] ),
        .a_out(\a_w[59] ),
        .\a_out_reg[8]_0 (\a_w[58] ),
        .acc_reg_0(\state_reg_n_0_[0] ),
        .acc_reg_1(\state_reg_n_0_[1] ),
        .acc_reg_2(\g_row[7].g_col[1].u_pe_n_0 ),
        .b_in(\b_w[35] ),
        .c_flat(c_flat[1919:1888]),
        .clk(clk),
        .en(\g_row[5].g_col[1].u_pe_n_1 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[7].g_col[3].u_pe_n_0 ));
  pe_59 \g_row[7].g_col[4].u_pe 
       (.E(busy),
        .a_in(\a_w[57] ),
        .a_out(\a_w[60] ),
        .\a_out_reg[8]_0 (\a_w[59] ),
        .acc_reg_0(\g_row[7].g_col[3].u_pe_n_0 ),
        .acc_reg_1(\g_row[7].g_col[1].u_pe_n_0 ),
        .b_in(\b_w[36] ),
        .c_flat(c_flat[1951:1920]),
        .clk(clk),
        .en(\g_row[7].g_col[6].u_pe_n_33 ),
        .pe_rst(pe_rst));
  pe_60 \g_row[7].g_col[5].u_pe 
       (.a_out(\a_w[58] ),
        .acc_reg_0(\g_row[7].g_col[3].u_pe_n_0 ),
        .acc_reg_1(\g_row[7].g_col[1].u_pe_n_0 ),
        .acc_reg_2(\state_reg_n_0_[0] ),
        .acc_reg_3(\state_reg_n_0_[1] ),
        .b_out(\b_w[37] ),
        .c_flat(c_flat[1983:1952]),
        .clk(clk),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[7].g_col[5].u_pe_n_32 ));
  pe_61 \g_row[7].g_col[6].u_pe 
       (.a_out(\a_w[59] ),
        .acc_reg_0(\g_row[7].g_col[3].u_pe_n_0 ),
        .acc_reg_1(\state_reg_n_0_[0] ),
        .acc_reg_2(\state_reg_n_0_[1] ),
        .b_out(\b_w[38] ),
        .c_flat(c_flat[2015:1984]),
        .clk(clk),
        .en(\g_row[7].g_col[6].u_pe_n_33 ),
        .pe_rst(pe_rst),
        .\state_reg[0] (\g_row[7].g_col[6].u_pe_n_32 ));
  pe_62 \g_row[7].g_col[7].u_pe 
       (.a_out(\a_w[60] ),
        .acc_reg_0(\g_row[7].g_col[3].u_pe_n_0 ),
        .acc_reg_1(\g_row[7].g_col[6].u_pe_n_32 ),
        .acc_reg_2(\g_row[7].g_col[5].u_pe_n_32 ),
        .b_out(\b_w[39] ),
        .c_flat(c_flat[2047:2016]),
        .clk(clk),
        .pe_rst(pe_rst));
  FDRE \g_skew_a[1].g_dn.sr_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_17 ),
        .Q(\g_skew_a[1].g_dn.sr [0]),
        .R(pe_rst));
  FDRE \g_skew_a[1].g_dn.sr_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_16 ),
        .Q(\g_skew_a[1].g_dn.sr [1]),
        .R(pe_rst));
  FDRE \g_skew_a[1].g_dn.sr_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_15 ),
        .Q(\g_skew_a[1].g_dn.sr [2]),
        .R(pe_rst));
  FDRE \g_skew_a[1].g_dn.sr_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_14 ),
        .Q(\g_skew_a[1].g_dn.sr [3]),
        .R(pe_rst));
  FDRE \g_skew_a[1].g_dn.sr_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_13 ),
        .Q(\g_skew_a[1].g_dn.sr [4]),
        .R(pe_rst));
  FDRE \g_skew_a[1].g_dn.sr_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_12 ),
        .Q(\g_skew_a[1].g_dn.sr [5]),
        .R(pe_rst));
  FDRE \g_skew_a[1].g_dn.sr_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_11 ),
        .Q(\g_skew_a[1].g_dn.sr [6]),
        .R(pe_rst));
  FDRE \g_skew_a[1].g_dn.sr_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_10 ),
        .Q(\g_skew_a[1].g_dn.sr [7]),
        .R(pe_rst));
  FDRE \g_skew_a[1].g_dn.sr_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_9 ),
        .Q(\g_skew_a[1].g_dn.sr [8]),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[2].g_col[0].u_pe_n_8 ),
        .Q(\g_skew_a[2].g_dn.sr_reg_n_0_[0] ),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[2].g_dn.sr_reg_n_0_[1] ),
        .Q(\g_row[2].g_col[0].a_in [1]),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[2].g_dn.sr_reg_n_0_[2] ),
        .Q(\g_row[2].g_col[0].a_in [2]),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[2].g_dn.sr_reg_n_0_[3] ),
        .Q(\g_row[2].g_col[0].a_in [3]),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[2].g_dn.sr_reg_n_0_[4] ),
        .Q(\g_row[2].g_col[0].a_in [4]),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[2].g_dn.sr_reg_n_0_[5] ),
        .Q(\g_row[2].g_col[0].a_in [5]),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[2].g_dn.sr_reg_n_0_[6] ),
        .Q(\g_row[2].g_col[0].a_in [6]),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[16] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[2].g_dn.sr_reg_n_0_[7] ),
        .Q(\g_row[2].g_col[0].a_in [7]),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[17] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[2].g_dn.sr_reg_n_0_[8] ),
        .Q(\g_row[2].g_col[0].a_in [8]),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[2].g_col[0].u_pe_n_7 ),
        .Q(\g_skew_a[2].g_dn.sr_reg_n_0_[1] ),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[2].g_col[0].u_pe_n_6 ),
        .Q(\g_skew_a[2].g_dn.sr_reg_n_0_[2] ),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[2].g_col[0].u_pe_n_5 ),
        .Q(\g_skew_a[2].g_dn.sr_reg_n_0_[3] ),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[2].g_col[0].u_pe_n_4 ),
        .Q(\g_skew_a[2].g_dn.sr_reg_n_0_[4] ),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[2].g_col[0].u_pe_n_3 ),
        .Q(\g_skew_a[2].g_dn.sr_reg_n_0_[5] ),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[2].g_col[0].u_pe_n_2 ),
        .Q(\g_skew_a[2].g_dn.sr_reg_n_0_[6] ),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[2].g_col[0].u_pe_n_1 ),
        .Q(\g_skew_a[2].g_dn.sr_reg_n_0_[7] ),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[2].g_col[0].u_pe_n_0 ),
        .Q(\g_skew_a[2].g_dn.sr_reg_n_0_[8] ),
        .R(pe_rst));
  FDRE \g_skew_a[2].g_dn.sr_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[2].g_dn.sr_reg_n_0_[0] ),
        .Q(\g_row[2].g_col[0].a_in [0]),
        .R(pe_rst));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[3].g_dn.sr[0]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[27]),
        .O(\g_skew_a[3].g_dn.sr[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[3].g_dn.sr[1]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[28]),
        .O(\g_skew_a[3].g_dn.sr[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[3].g_dn.sr[2]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[29]),
        .O(\g_skew_a[3].g_dn.sr[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[3].g_dn.sr[3]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[30]),
        .O(\g_skew_a[3].g_dn.sr[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[3].g_dn.sr[4]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[31]),
        .O(\g_skew_a[3].g_dn.sr[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[3].g_dn.sr[5]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[32]),
        .O(\g_skew_a[3].g_dn.sr[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[3].g_dn.sr[6]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[33]),
        .O(\g_skew_a[3].g_dn.sr[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[3].g_dn.sr[7]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[34]),
        .O(\g_skew_a[3].g_dn.sr[7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[3].g_dn.sr[8]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[35]),
        .O(\g_skew_a[3].g_dn.sr[8]_i_1_n_0 ));
  FDRE \g_skew_a[3].g_dn.sr_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr[0]_i_1_n_0 ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[0] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[1] ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[10] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[2] ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[11] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[3] ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[12] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[4] ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[13] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[5] ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[14] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[6] ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[15] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[16] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[7] ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[16] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[17] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[8] ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[17] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[18] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[9] ),
        .Q(\g_row[3].g_col[0].a_in [0]),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[19] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[10] ),
        .Q(\g_row[3].g_col[0].a_in [1]),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr[1]_i_1_n_0 ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[1] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[20] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[11] ),
        .Q(\g_row[3].g_col[0].a_in [2]),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[21] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[12] ),
        .Q(\g_row[3].g_col[0].a_in [3]),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[22] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[13] ),
        .Q(\g_row[3].g_col[0].a_in [4]),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[23] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[14] ),
        .Q(\g_row[3].g_col[0].a_in [5]),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[24] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[15] ),
        .Q(\g_row[3].g_col[0].a_in [6]),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[25] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[16] ),
        .Q(\g_row[3].g_col[0].a_in [7]),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[26] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[17] ),
        .Q(\g_row[3].g_col[0].a_in [8]),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr[2]_i_1_n_0 ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[2] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr[3]_i_1_n_0 ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[3] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr[4]_i_1_n_0 ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[4] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr[5]_i_1_n_0 ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[5] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr[6]_i_1_n_0 ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[6] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr[7]_i_1_n_0 ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[7] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr[8]_i_1_n_0 ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[8] ),
        .R(pe_rst));
  FDRE \g_skew_a[3].g_dn.sr_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[3].g_dn.sr_reg_n_0_[0] ),
        .Q(\g_skew_a[3].g_dn.sr_reg_n_0_[9] ),
        .R(pe_rst));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[4].g_dn.sr[0]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[36]),
        .O(\g_skew_a[4].g_dn.sr[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[4].g_dn.sr[1]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[37]),
        .O(\g_skew_a[4].g_dn.sr[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[4].g_dn.sr[2]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[38]),
        .O(\g_skew_a[4].g_dn.sr[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[4].g_dn.sr[3]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[39]),
        .O(\g_skew_a[4].g_dn.sr[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[4].g_dn.sr[4]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[40]),
        .O(\g_skew_a[4].g_dn.sr[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[4].g_dn.sr[5]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[41]),
        .O(\g_skew_a[4].g_dn.sr[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[4].g_dn.sr[6]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[42]),
        .O(\g_skew_a[4].g_dn.sr[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[4].g_dn.sr[7]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[43]),
        .O(\g_skew_a[4].g_dn.sr[7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[4].g_dn.sr[8]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[44]),
        .O(\g_skew_a[4].g_dn.sr[8]_i_1_n_0 ));
  FDRE \g_skew_a[4].g_dn.sr_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr[0]_i_1_n_0 ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[0] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[1] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[10] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[2] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[11] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[3] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[12] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[4] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[13] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[5] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[14] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[6] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[15] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[16] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[7] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[16] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[17] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[8] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[17] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[18] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[9] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[18] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[19] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[10] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[19] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr[1]_i_1_n_0 ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[1] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[20] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[11] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[20] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[21] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[12] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[21] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[22] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[13] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[22] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[23] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[14] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[23] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[24] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[15] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[24] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[25] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[16] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[25] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[26] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[17] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[26] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[27] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[18] ),
        .Q(\g_row[4].g_col[0].a_in [0]),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[28] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[19] ),
        .Q(\g_row[4].g_col[0].a_in [1]),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[29] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[20] ),
        .Q(\g_row[4].g_col[0].a_in [2]),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr[2]_i_1_n_0 ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[2] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[30] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[21] ),
        .Q(\g_row[4].g_col[0].a_in [3]),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[31] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[22] ),
        .Q(\g_row[4].g_col[0].a_in [4]),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[32] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[23] ),
        .Q(\g_row[4].g_col[0].a_in [5]),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[33] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[24] ),
        .Q(\g_row[4].g_col[0].a_in [6]),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[34] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[25] ),
        .Q(\g_row[4].g_col[0].a_in [7]),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[35] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[26] ),
        .Q(\g_row[4].g_col[0].a_in [8]),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr[3]_i_1_n_0 ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[3] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr[4]_i_1_n_0 ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[4] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr[5]_i_1_n_0 ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[5] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr[6]_i_1_n_0 ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[6] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr[7]_i_1_n_0 ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[7] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr[8]_i_1_n_0 ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[8] ),
        .R(pe_rst));
  FDRE \g_skew_a[4].g_dn.sr_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[4].g_dn.sr_reg_n_0_[0] ),
        .Q(\g_skew_a[4].g_dn.sr_reg_n_0_[9] ),
        .R(pe_rst));
  (* srl_bus_name = "\\g_skew_a[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_a[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[46]),
        .O(\g_skew_a[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_a[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[47]),
        .O(\g_skew_a[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_a[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[48]),
        .O(\g_skew_a[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_a[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[49]),
        .O(\g_skew_a[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_a[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[50]),
        .O(\g_skew_a[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_a[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[51]),
        .O(\g_skew_a[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[5].g_dn.sr_reg[16]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_a[5].g_dn.sr_reg[16]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[5].g_dn.sr_reg[16]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[16]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[5].g_dn.sr_reg[16]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[52]),
        .O(\g_skew_a[5].g_dn.sr_reg[16]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[5].g_dn.sr_reg[17]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_a[5].g_dn.sr_reg[17]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[5].g_dn.sr_reg[17]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[17]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[5].g_dn.sr_reg[17]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[53]),
        .O(\g_skew_a[5].g_dn.sr_reg[17]_srl2___g_skew_b_r_0_i_1_n_0 ));
  FDRE \g_skew_a[5].g_dn.sr_reg[18]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[18]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[5].g_dn.sr_reg[19]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[19]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[5].g_dn.sr_reg[20]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[20]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[5].g_dn.sr_reg[21]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[21]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[5].g_dn.sr_reg[22]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[22]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[5].g_dn.sr_reg[23]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[23]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[5].g_dn.sr_reg[24]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[24]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[5].g_dn.sr_reg[25]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg[16]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[25]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[5].g_dn.sr_reg[26]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg[17]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[26]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[5].g_dn.sr_reg[27] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[5].g_col[0].u_pe_n_8 ),
        .Q(\g_skew_a[5].g_dn.sr_reg_n_0_[27] ),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[28] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[5].g_col[0].u_pe_n_7 ),
        .Q(\g_skew_a[5].g_dn.sr_reg_n_0_[28] ),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[29] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[5].g_col[0].u_pe_n_6 ),
        .Q(\g_skew_a[5].g_dn.sr_reg_n_0_[29] ),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[30] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[5].g_col[0].u_pe_n_5 ),
        .Q(\g_skew_a[5].g_dn.sr_reg_n_0_[30] ),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[31] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[5].g_col[0].u_pe_n_4 ),
        .Q(\g_skew_a[5].g_dn.sr_reg_n_0_[31] ),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[32] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[5].g_col[0].u_pe_n_3 ),
        .Q(\g_skew_a[5].g_dn.sr_reg_n_0_[32] ),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[33] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[5].g_col[0].u_pe_n_2 ),
        .Q(\g_skew_a[5].g_dn.sr_reg_n_0_[33] ),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[34] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[5].g_col[0].u_pe_n_1 ),
        .Q(\g_skew_a[5].g_dn.sr_reg_n_0_[34] ),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[35] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[5].g_col[0].u_pe_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg_n_0_[35] ),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[36] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg_n_0_[27] ),
        .Q(\g_row[5].g_col[0].a_in [0]),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[37] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg_n_0_[28] ),
        .Q(\g_row[5].g_col[0].a_in [1]),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[38] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg_n_0_[29] ),
        .Q(\g_row[5].g_col[0].a_in [2]),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[39] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg_n_0_[30] ),
        .Q(\g_row[5].g_col[0].a_in [3]),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[40] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg_n_0_[31] ),
        .Q(\g_row[5].g_col[0].a_in [4]),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[41] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg_n_0_[32] ),
        .Q(\g_row[5].g_col[0].a_in [5]),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[42] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg_n_0_[33] ),
        .Q(\g_row[5].g_col[0].a_in [6]),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[43] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg_n_0_[34] ),
        .Q(\g_row[5].g_col[0].a_in [7]),
        .R(pe_rst));
  FDRE \g_skew_a[5].g_dn.sr_reg[44] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[5].g_dn.sr_reg_n_0_[35] ),
        .Q(\g_row[5].g_col[0].a_in [8]),
        .R(pe_rst));
  (* srl_bus_name = "\\g_skew_a[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_a[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_a[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[45]),
        .O(\g_skew_a[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_a[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[54]),
        .O(\g_skew_a[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_a[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[55]),
        .O(\g_skew_a[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_a[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[56]),
        .O(\g_skew_a[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_a[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[57]),
        .O(\g_skew_a[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_a[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[58]),
        .O(\g_skew_a[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_a[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[59]),
        .O(\g_skew_a[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[6].g_dn.sr_reg[24]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_a[6].g_dn.sr_reg[24]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[6].g_dn.sr_reg[24]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[24]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[6].g_dn.sr_reg[24]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[60]),
        .O(\g_skew_a[6].g_dn.sr_reg[24]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[6].g_dn.sr_reg[25]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_a[6].g_dn.sr_reg[25]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[6].g_dn.sr_reg[25]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[25]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[6].g_dn.sr_reg[25]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[61]),
        .O(\g_skew_a[6].g_dn.sr_reg[25]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[6].g_dn.sr_reg[26]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_a[6].g_dn.sr_reg[26]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[6].g_dn.sr_reg[26]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[26]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[6].g_dn.sr_reg[26]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[62]),
        .O(\g_skew_a[6].g_dn.sr_reg[26]_srl3___g_skew_b_r_1_i_1_n_0 ));
  FDRE \g_skew_a[6].g_dn.sr_reg[27]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[27]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[6].g_dn.sr_reg[28]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[28]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[6].g_dn.sr_reg[29]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[29]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[6].g_dn.sr_reg[30]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[30]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[6].g_dn.sr_reg[31]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[31]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[6].g_dn.sr_reg[32]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[32]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[6].g_dn.sr_reg[33]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg[24]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[33]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[6].g_dn.sr_reg[34]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg[25]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[34]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[6].g_dn.sr_reg[35]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg[26]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg[35]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[6].g_dn.sr_reg[36] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[6].g_col[0].u_pe_n_8 ),
        .Q(\g_skew_a[6].g_dn.sr_reg_n_0_[36] ),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[37] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[6].g_col[0].u_pe_n_7 ),
        .Q(\g_skew_a[6].g_dn.sr_reg_n_0_[37] ),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[38] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[6].g_col[0].u_pe_n_6 ),
        .Q(\g_skew_a[6].g_dn.sr_reg_n_0_[38] ),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[39] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[6].g_col[0].u_pe_n_5 ),
        .Q(\g_skew_a[6].g_dn.sr_reg_n_0_[39] ),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[40] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[6].g_col[0].u_pe_n_4 ),
        .Q(\g_skew_a[6].g_dn.sr_reg_n_0_[40] ),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[41] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[6].g_col[0].u_pe_n_3 ),
        .Q(\g_skew_a[6].g_dn.sr_reg_n_0_[41] ),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[42] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[6].g_col[0].u_pe_n_2 ),
        .Q(\g_skew_a[6].g_dn.sr_reg_n_0_[42] ),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[43] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[6].g_col[0].u_pe_n_1 ),
        .Q(\g_skew_a[6].g_dn.sr_reg_n_0_[43] ),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[44] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[6].g_col[0].u_pe_n_0 ),
        .Q(\g_skew_a[6].g_dn.sr_reg_n_0_[44] ),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[45] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg_n_0_[36] ),
        .Q(\g_row[6].g_col[0].a_in [0]),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[46] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg_n_0_[37] ),
        .Q(\g_row[6].g_col[0].a_in [1]),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[47] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg_n_0_[38] ),
        .Q(\g_row[6].g_col[0].a_in [2]),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[48] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg_n_0_[39] ),
        .Q(\g_row[6].g_col[0].a_in [3]),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[49] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg_n_0_[40] ),
        .Q(\g_row[6].g_col[0].a_in [4]),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[50] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg_n_0_[41] ),
        .Q(\g_row[6].g_col[0].a_in [5]),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[51] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg_n_0_[42] ),
        .Q(\g_row[6].g_col[0].a_in [6]),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[52] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg_n_0_[43] ),
        .Q(\g_row[6].g_col[0].a_in [7]),
        .R(pe_rst));
  FDRE \g_skew_a[6].g_dn.sr_reg[53] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[6].g_dn.sr_reg_n_0_[44] ),
        .Q(\g_row[6].g_col[0].a_in [8]),
        .R(pe_rst));
  (* srl_bus_name = "\\g_skew_a[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_a[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[63]),
        .O(\g_skew_a[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_a[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[64]),
        .O(\g_skew_a[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_a[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[65]),
        .O(\g_skew_a[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_a[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[66]),
        .O(\g_skew_a[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_a[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[67]),
        .O(\g_skew_a[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[7].g_dn.sr_reg[32]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_a[7].g_dn.sr_reg[32]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[7].g_dn.sr_reg[32]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[32]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[7].g_dn.sr_reg[32]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[68]),
        .O(\g_skew_a[7].g_dn.sr_reg[32]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[7].g_dn.sr_reg[33]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_a[7].g_dn.sr_reg[33]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[7].g_dn.sr_reg[33]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[33]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[7].g_dn.sr_reg[33]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[69]),
        .O(\g_skew_a[7].g_dn.sr_reg[33]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[7].g_dn.sr_reg[34]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_a[7].g_dn.sr_reg[34]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[7].g_dn.sr_reg[34]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[34]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[7].g_dn.sr_reg[34]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[70]),
        .O(\g_skew_a[7].g_dn.sr_reg[34]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_a[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_a[7].g_dn.sr_reg[35]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_a[7].g_dn.sr_reg[35]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_a[7].g_dn.sr_reg[35]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[35]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_a[7].g_dn.sr_reg[35]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(a_col[71]),
        .O(\g_skew_a[7].g_dn.sr_reg[35]_srl4___g_skew_b_r_2_i_1_n_0 ));
  FDRE \g_skew_a[7].g_dn.sr_reg[36]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[36]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[7].g_dn.sr_reg[37]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[37]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[7].g_dn.sr_reg[38]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[38]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[7].g_dn.sr_reg[39]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[39]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[7].g_dn.sr_reg[40]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[40]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[7].g_dn.sr_reg[41]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg[32]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[41]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[7].g_dn.sr_reg[42]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg[33]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[42]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[7].g_dn.sr_reg[43]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg[34]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[43]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[7].g_dn.sr_reg[44]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg[35]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg[44]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_a[7].g_dn.sr_reg[45] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[7].g_col[0].u_pe_n_8 ),
        .Q(\g_skew_a[7].g_dn.sr_reg_n_0_[45] ),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[46] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[7].g_col[0].u_pe_n_7 ),
        .Q(\g_skew_a[7].g_dn.sr_reg_n_0_[46] ),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[47] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[7].g_col[0].u_pe_n_6 ),
        .Q(\g_skew_a[7].g_dn.sr_reg_n_0_[47] ),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[48] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[7].g_col[0].u_pe_n_5 ),
        .Q(\g_skew_a[7].g_dn.sr_reg_n_0_[48] ),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[49] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[7].g_col[0].u_pe_n_4 ),
        .Q(\g_skew_a[7].g_dn.sr_reg_n_0_[49] ),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[50] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[7].g_col[0].u_pe_n_3 ),
        .Q(\g_skew_a[7].g_dn.sr_reg_n_0_[50] ),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[51] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[7].g_col[0].u_pe_n_2 ),
        .Q(\g_skew_a[7].g_dn.sr_reg_n_0_[51] ),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[52] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[7].g_col[0].u_pe_n_1 ),
        .Q(\g_skew_a[7].g_dn.sr_reg_n_0_[52] ),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[53] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[7].g_col[0].u_pe_n_0 ),
        .Q(\g_skew_a[7].g_dn.sr_reg_n_0_[53] ),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[54] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg_n_0_[45] ),
        .Q(\g_row[7].g_col[0].a_in [0]),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[55] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg_n_0_[46] ),
        .Q(\g_row[7].g_col[0].a_in [1]),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[56] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg_n_0_[47] ),
        .Q(\g_row[7].g_col[0].a_in [2]),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[57] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg_n_0_[48] ),
        .Q(\g_row[7].g_col[0].a_in [3]),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[58] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg_n_0_[49] ),
        .Q(\g_row[7].g_col[0].a_in [4]),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[59] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg_n_0_[50] ),
        .Q(\g_row[7].g_col[0].a_in [5]),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[60] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg_n_0_[51] ),
        .Q(\g_row[7].g_col[0].a_in [6]),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[61] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg_n_0_[52] ),
        .Q(\g_row[7].g_col[0].a_in [7]),
        .R(pe_rst));
  FDRE \g_skew_a[7].g_dn.sr_reg[62] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_a[7].g_dn.sr_reg_n_0_[53] ),
        .Q(\g_row[7].g_col[0].a_in [8]),
        .R(pe_rst));
  FDRE \g_skew_b[1].g_dn.sr_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_8 ),
        .Q(\g_skew_b[1].g_dn.sr [0]),
        .R(pe_rst));
  FDRE \g_skew_b[1].g_dn.sr_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_7 ),
        .Q(\g_skew_b[1].g_dn.sr [1]),
        .R(pe_rst));
  FDRE \g_skew_b[1].g_dn.sr_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_6 ),
        .Q(\g_skew_b[1].g_dn.sr [2]),
        .R(pe_rst));
  FDRE \g_skew_b[1].g_dn.sr_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_5 ),
        .Q(\g_skew_b[1].g_dn.sr [3]),
        .R(pe_rst));
  FDRE \g_skew_b[1].g_dn.sr_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_4 ),
        .Q(\g_skew_b[1].g_dn.sr [4]),
        .R(pe_rst));
  FDRE \g_skew_b[1].g_dn.sr_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_3 ),
        .Q(\g_skew_b[1].g_dn.sr [5]),
        .R(pe_rst));
  FDRE \g_skew_b[1].g_dn.sr_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_2 ),
        .Q(\g_skew_b[1].g_dn.sr [6]),
        .R(pe_rst));
  FDRE \g_skew_b[1].g_dn.sr_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[1].g_col[1].u_pe_n_1 ),
        .Q(\g_skew_b[1].g_dn.sr [7]),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[2].u_pe_n_7 ),
        .Q(\g_skew_b[2].g_dn.sr_reg_n_0_[0] ),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[2].g_dn.sr_reg_n_0_[2] ),
        .Q(\g_row[0].g_col[2].b_in [2]),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[2].g_dn.sr_reg_n_0_[3] ),
        .Q(\g_row[0].g_col[2].b_in [3]),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[2].g_dn.sr_reg_n_0_[4] ),
        .Q(\g_row[0].g_col[2].b_in [4]),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[2].g_dn.sr_reg_n_0_[5] ),
        .Q(\g_row[0].g_col[2].b_in [5]),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[2].g_dn.sr_reg_n_0_[6] ),
        .Q(\g_row[0].g_col[2].b_in [6]),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[2].g_dn.sr_reg_n_0_[7] ),
        .Q(\g_row[0].g_col[2].b_in [7]),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[2].u_pe_n_6 ),
        .Q(\g_skew_b[2].g_dn.sr_reg_n_0_[1] ),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[2].u_pe_n_5 ),
        .Q(\g_skew_b[2].g_dn.sr_reg_n_0_[2] ),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[2].u_pe_n_4 ),
        .Q(\g_skew_b[2].g_dn.sr_reg_n_0_[3] ),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[2].u_pe_n_3 ),
        .Q(\g_skew_b[2].g_dn.sr_reg_n_0_[4] ),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[2].u_pe_n_2 ),
        .Q(\g_skew_b[2].g_dn.sr_reg_n_0_[5] ),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[2].u_pe_n_1 ),
        .Q(\g_skew_b[2].g_dn.sr_reg_n_0_[6] ),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[2].u_pe_n_0 ),
        .Q(\g_skew_b[2].g_dn.sr_reg_n_0_[7] ),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[2].g_dn.sr_reg_n_0_[0] ),
        .Q(\g_row[0].g_col[2].b_in [0]),
        .R(pe_rst));
  FDRE \g_skew_b[2].g_dn.sr_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[2].g_dn.sr_reg_n_0_[1] ),
        .Q(\g_row[0].g_col[2].b_in [1]),
        .R(pe_rst));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[3].g_dn.sr[0]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[24]),
        .O(\g_skew_b[3].g_dn.sr[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[3].g_dn.sr[1]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[25]),
        .O(\g_skew_b[3].g_dn.sr[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[3].g_dn.sr[2]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[26]),
        .O(\g_skew_b[3].g_dn.sr[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[3].g_dn.sr[3]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[27]),
        .O(\g_skew_b[3].g_dn.sr[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[3].g_dn.sr[4]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[28]),
        .O(\g_skew_b[3].g_dn.sr[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[3].g_dn.sr[5]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[29]),
        .O(\g_skew_b[3].g_dn.sr[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[3].g_dn.sr[6]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[30]),
        .O(\g_skew_b[3].g_dn.sr[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[3].g_dn.sr[7]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[31]),
        .O(\g_skew_b[3].g_dn.sr[7]_i_1_n_0 ));
  FDRE \g_skew_b[3].g_dn.sr_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr[0]_i_1_n_0 ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[0] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[2] ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[10] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[3] ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[11] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[4] ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[12] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[5] ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[13] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[6] ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[14] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[7] ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[15] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[16] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[8] ),
        .Q(\g_row[0].g_col[3].b_in [0]),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[17] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[9] ),
        .Q(\g_row[0].g_col[3].b_in [1]),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[18] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[10] ),
        .Q(\g_row[0].g_col[3].b_in [2]),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[19] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[11] ),
        .Q(\g_row[0].g_col[3].b_in [3]),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr[1]_i_1_n_0 ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[1] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[20] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[12] ),
        .Q(\g_row[0].g_col[3].b_in [4]),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[21] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[13] ),
        .Q(\g_row[0].g_col[3].b_in [5]),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[22] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[14] ),
        .Q(\g_row[0].g_col[3].b_in [6]),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[23] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[15] ),
        .Q(\g_row[0].g_col[3].b_in [7]),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr[2]_i_1_n_0 ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[2] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr[3]_i_1_n_0 ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[3] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr[4]_i_1_n_0 ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[4] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr[5]_i_1_n_0 ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[5] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr[6]_i_1_n_0 ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[6] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr[7]_i_1_n_0 ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[7] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[0] ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[8] ),
        .R(pe_rst));
  FDRE \g_skew_b[3].g_dn.sr_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[3].g_dn.sr_reg_n_0_[1] ),
        .Q(\g_skew_b[3].g_dn.sr_reg_n_0_[9] ),
        .R(pe_rst));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[4].g_dn.sr[0]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[32]),
        .O(\g_skew_b[4].g_dn.sr[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[4].g_dn.sr[1]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[33]),
        .O(\g_skew_b[4].g_dn.sr[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[4].g_dn.sr[2]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[34]),
        .O(\g_skew_b[4].g_dn.sr[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[4].g_dn.sr[3]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[35]),
        .O(\g_skew_b[4].g_dn.sr[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[4].g_dn.sr[4]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[36]),
        .O(\g_skew_b[4].g_dn.sr[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[4].g_dn.sr[5]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[37]),
        .O(\g_skew_b[4].g_dn.sr[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[4].g_dn.sr[6]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[38]),
        .O(\g_skew_b[4].g_dn.sr[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[4].g_dn.sr[7]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[39]),
        .O(\g_skew_b[4].g_dn.sr[7]_i_1_n_0 ));
  FDRE \g_skew_b[4].g_dn.sr_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr[0]_i_1_n_0 ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[0] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[2] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[10] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[11] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[3] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[11] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[12] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[4] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[12] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[13] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[5] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[13] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[14] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[6] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[14] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[15] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[7] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[15] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[16] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[8] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[16] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[17] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[9] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[17] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[18] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[10] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[18] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[19] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[11] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[19] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr[1]_i_1_n_0 ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[1] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[20] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[12] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[20] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[21] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[13] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[21] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[22] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[14] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[22] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[23] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[15] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[23] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[24] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[16] ),
        .Q(\g_row[0].g_col[4].b_in [0]),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[25] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[17] ),
        .Q(\g_row[0].g_col[4].b_in [1]),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[26] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[18] ),
        .Q(\g_row[0].g_col[4].b_in [2]),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[27] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[19] ),
        .Q(\g_row[0].g_col[4].b_in [3]),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[28] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[20] ),
        .Q(\g_row[0].g_col[4].b_in [4]),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[29] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[21] ),
        .Q(\g_row[0].g_col[4].b_in [5]),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr[2]_i_1_n_0 ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[2] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[30] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[22] ),
        .Q(\g_row[0].g_col[4].b_in [6]),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[31] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[23] ),
        .Q(\g_row[0].g_col[4].b_in [7]),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr[3]_i_1_n_0 ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[3] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr[4]_i_1_n_0 ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[4] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr[5]_i_1_n_0 ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[5] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr[6]_i_1_n_0 ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[6] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr[7]_i_1_n_0 ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[7] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[0] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[8] ),
        .R(pe_rst));
  FDRE \g_skew_b[4].g_dn.sr_reg[9] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[4].g_dn.sr_reg_n_0_[1] ),
        .Q(\g_skew_b[4].g_dn.sr_reg_n_0_[9] ),
        .R(pe_rst));
  (* srl_bus_name = "\\g_skew_b[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_b[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[42]),
        .O(\g_skew_b[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_b[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[43]),
        .O(\g_skew_b[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_b[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[44]),
        .O(\g_skew_b[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_b[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[45]),
        .O(\g_skew_b[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_b[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[46]),
        .O(\g_skew_b[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_b[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[47]),
        .O(\g_skew_b[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_i_1_n_0 ));
  FDRE \g_skew_b[5].g_dn.sr_reg[16]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg[8]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[16]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[5].g_dn.sr_reg[17]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[17]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[5].g_dn.sr_reg[18]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg[10]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[18]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[5].g_dn.sr_reg[19]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg[11]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[19]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[5].g_dn.sr_reg[20]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg[12]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[20]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[5].g_dn.sr_reg[21]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg[13]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[21]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[5].g_dn.sr_reg[22]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg[14]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[22]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[5].g_dn.sr_reg[23]_g_skew_b_r_1 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg[15]_srl2___g_skew_b_r_0_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[23]_g_skew_b_r_1_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[5].g_dn.sr_reg[24] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[5].u_pe_n_7 ),
        .Q(\g_skew_b[5].g_dn.sr_reg_n_0_[24] ),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[25] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[5].u_pe_n_6 ),
        .Q(\g_skew_b[5].g_dn.sr_reg_n_0_[25] ),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[26] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[5].u_pe_n_5 ),
        .Q(\g_skew_b[5].g_dn.sr_reg_n_0_[26] ),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[27] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[5].u_pe_n_4 ),
        .Q(\g_skew_b[5].g_dn.sr_reg_n_0_[27] ),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[28] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[5].u_pe_n_3 ),
        .Q(\g_skew_b[5].g_dn.sr_reg_n_0_[28] ),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[29] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[5].u_pe_n_2 ),
        .Q(\g_skew_b[5].g_dn.sr_reg_n_0_[29] ),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[30] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[5].u_pe_n_1 ),
        .Q(\g_skew_b[5].g_dn.sr_reg_n_0_[30] ),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[31] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[5].u_pe_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg_n_0_[31] ),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[32] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg_n_0_[24] ),
        .Q(\g_row[0].g_col[5].b_in [0]),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[33] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg_n_0_[25] ),
        .Q(\g_row[0].g_col[5].b_in [1]),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[34] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg_n_0_[26] ),
        .Q(\g_row[0].g_col[5].b_in [2]),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[35] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg_n_0_[27] ),
        .Q(\g_row[0].g_col[5].b_in [3]),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[36] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg_n_0_[28] ),
        .Q(\g_row[0].g_col[5].b_in [4]),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[37] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg_n_0_[29] ),
        .Q(\g_row[0].g_col[5].b_in [5]),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[38] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg_n_0_[30] ),
        .Q(\g_row[0].g_col[5].b_in [6]),
        .R(pe_rst));
  FDRE \g_skew_b[5].g_dn.sr_reg[39] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[5].g_dn.sr_reg_n_0_[31] ),
        .Q(\g_row[0].g_col[5].b_in [7]),
        .R(pe_rst));
  (* srl_bus_name = "\\g_skew_b[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[5].g_dn.sr_reg[8]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_b[5].g_dn.sr_reg[8]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[5].g_dn.sr_reg[8]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[8]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[5].g_dn.sr_reg[8]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[40]),
        .O(\g_skew_b[5].g_dn.sr_reg[8]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[5].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0 " *) 
  SRL16E \g_skew_b[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_i_1_n_0 ),
        .Q(\g_skew_b[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[41]),
        .O(\g_skew_b[5].g_dn.sr_reg[9]_srl2___g_skew_b_r_0_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[6].g_dn.sr_reg[16]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_b[6].g_dn.sr_reg[16]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[6].g_dn.sr_reg[16]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[16]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[6].g_dn.sr_reg[16]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[48]),
        .O(\g_skew_b[6].g_dn.sr_reg[16]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[6].g_dn.sr_reg[17]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_b[6].g_dn.sr_reg[17]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[6].g_dn.sr_reg[17]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[17]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[6].g_dn.sr_reg[17]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[49]),
        .O(\g_skew_b[6].g_dn.sr_reg[17]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_b[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[50]),
        .O(\g_skew_b[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_b[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[51]),
        .O(\g_skew_b[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_b[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[52]),
        .O(\g_skew_b[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_b[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[53]),
        .O(\g_skew_b[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_b[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[54]),
        .O(\g_skew_b[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[6].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1 " *) 
  SRL16E \g_skew_b[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1 
       (.A0(1'b0),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_i_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[55]),
        .O(\g_skew_b[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_i_1_n_0 ));
  FDRE \g_skew_b[6].g_dn.sr_reg[24]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg[16]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[24]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[6].g_dn.sr_reg[25]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg[17]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[25]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[6].g_dn.sr_reg[26]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg[18]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[26]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[6].g_dn.sr_reg[27]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg[19]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[27]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[6].g_dn.sr_reg[28]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg[20]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[28]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[6].g_dn.sr_reg[29]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg[21]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[29]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[6].g_dn.sr_reg[30]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg[22]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[30]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[6].g_dn.sr_reg[31]_g_skew_b_r_2 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg[23]_srl3___g_skew_b_r_1_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg[31]_g_skew_b_r_2_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[6].g_dn.sr_reg[32] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[6].u_pe_n_7 ),
        .Q(\g_skew_b[6].g_dn.sr_reg_n_0_[32] ),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[33] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[6].u_pe_n_6 ),
        .Q(\g_skew_b[6].g_dn.sr_reg_n_0_[33] ),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[34] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[6].u_pe_n_5 ),
        .Q(\g_skew_b[6].g_dn.sr_reg_n_0_[34] ),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[35] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[6].u_pe_n_4 ),
        .Q(\g_skew_b[6].g_dn.sr_reg_n_0_[35] ),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[36] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[6].u_pe_n_3 ),
        .Q(\g_skew_b[6].g_dn.sr_reg_n_0_[36] ),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[37] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[6].u_pe_n_2 ),
        .Q(\g_skew_b[6].g_dn.sr_reg_n_0_[37] ),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[38] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[6].u_pe_n_1 ),
        .Q(\g_skew_b[6].g_dn.sr_reg_n_0_[38] ),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[39] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[6].u_pe_n_0 ),
        .Q(\g_skew_b[6].g_dn.sr_reg_n_0_[39] ),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[40] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg_n_0_[32] ),
        .Q(\g_row[0].g_col[6].b_in [0]),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[41] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg_n_0_[33] ),
        .Q(\g_row[0].g_col[6].b_in [1]),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[42] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg_n_0_[34] ),
        .Q(\g_row[0].g_col[6].b_in [2]),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[43] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg_n_0_[35] ),
        .Q(\g_row[0].g_col[6].b_in [3]),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[44] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg_n_0_[36] ),
        .Q(\g_row[0].g_col[6].b_in [4]),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[45] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg_n_0_[37] ),
        .Q(\g_row[0].g_col[6].b_in [5]),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[46] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg_n_0_[38] ),
        .Q(\g_row[0].g_col[6].b_in [6]),
        .R(pe_rst));
  FDRE \g_skew_b[6].g_dn.sr_reg[47] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[6].g_dn.sr_reg_n_0_[39] ),
        .Q(\g_row[0].g_col[6].b_in [7]),
        .R(pe_rst));
  (* srl_bus_name = "\\g_skew_b[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[7].g_dn.sr_reg[24]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_b[7].g_dn.sr_reg[24]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[7].g_dn.sr_reg[24]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[24]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[7].g_dn.sr_reg[24]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[56]),
        .O(\g_skew_b[7].g_dn.sr_reg[24]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[7].g_dn.sr_reg[25]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_b[7].g_dn.sr_reg[25]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[7].g_dn.sr_reg[25]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[25]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[7].g_dn.sr_reg[25]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[57]),
        .O(\g_skew_b[7].g_dn.sr_reg[25]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[7].g_dn.sr_reg[26]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_b[7].g_dn.sr_reg[26]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[7].g_dn.sr_reg[26]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[26]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[7].g_dn.sr_reg[26]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[58]),
        .O(\g_skew_b[7].g_dn.sr_reg[26]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_b[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[59]),
        .O(\g_skew_b[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_b[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[60]),
        .O(\g_skew_b[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_b[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[61]),
        .O(\g_skew_b[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_b[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[62]),
        .O(\g_skew_b[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_i_1_n_0 ));
  (* srl_bus_name = "\\g_skew_b[7].g_dn.sr_reg " *) 
  (* srl_name = "\\g_skew_b[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2 " *) 
  SRL16E \g_skew_b[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk),
        .D(\g_skew_b[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_i_1_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \g_skew_b[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(b_row[63]),
        .O(\g_skew_b[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_i_1_n_0 ));
  FDRE \g_skew_b[7].g_dn.sr_reg[32]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg[24]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[32]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[7].g_dn.sr_reg[33]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg[25]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[33]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[7].g_dn.sr_reg[34]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg[26]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[34]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[7].g_dn.sr_reg[35]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg[27]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[35]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[7].g_dn.sr_reg[36]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg[28]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[36]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[7].g_dn.sr_reg[37]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg[29]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[37]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[7].g_dn.sr_reg[38]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg[30]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[38]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[7].g_dn.sr_reg[39]_g_skew_b_r_3 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg[31]_srl4___g_skew_b_r_2_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg[39]_g_skew_b_r_3_n_0 ),
        .R(1'b0));
  FDRE \g_skew_b[7].g_dn.sr_reg[40] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[7].u_pe_n_7 ),
        .Q(\g_skew_b[7].g_dn.sr_reg_n_0_[40] ),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[41] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[7].u_pe_n_6 ),
        .Q(\g_skew_b[7].g_dn.sr_reg_n_0_[41] ),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[42] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[7].u_pe_n_5 ),
        .Q(\g_skew_b[7].g_dn.sr_reg_n_0_[42] ),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[43] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[7].u_pe_n_4 ),
        .Q(\g_skew_b[7].g_dn.sr_reg_n_0_[43] ),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[44] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[7].u_pe_n_3 ),
        .Q(\g_skew_b[7].g_dn.sr_reg_n_0_[44] ),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[45] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[7].u_pe_n_2 ),
        .Q(\g_skew_b[7].g_dn.sr_reg_n_0_[45] ),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[46] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[7].u_pe_n_1 ),
        .Q(\g_skew_b[7].g_dn.sr_reg_n_0_[46] ),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[47] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_row[0].g_col[7].u_pe_n_0 ),
        .Q(\g_skew_b[7].g_dn.sr_reg_n_0_[47] ),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[48] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg_n_0_[40] ),
        .Q(\g_row[0].g_col[7].b_in [0]),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[49] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg_n_0_[41] ),
        .Q(\g_row[0].g_col[7].b_in [1]),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[50] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg_n_0_[42] ),
        .Q(\g_row[0].g_col[7].b_in [2]),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[51] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg_n_0_[43] ),
        .Q(\g_row[0].g_col[7].b_in [3]),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[52] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg_n_0_[44] ),
        .Q(\g_row[0].g_col[7].b_in [4]),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[53] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg_n_0_[45] ),
        .Q(\g_row[0].g_col[7].b_in [5]),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[54] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg_n_0_[46] ),
        .Q(\g_row[0].g_col[7].b_in [6]),
        .R(pe_rst));
  FDRE \g_skew_b[7].g_dn.sr_reg[55] 
       (.C(clk),
        .CE(1'b1),
        .D(\g_skew_b[7].g_dn.sr_reg_n_0_[47] ),
        .Q(\g_row[0].g_col[7].b_in [7]),
        .R(pe_rst));
  FDRE g_skew_b_r
       (.C(clk),
        .CE(1'b1),
        .D(1'b1),
        .Q(g_skew_b_r_n_0),
        .R(pe_rst));
  FDRE g_skew_b_r_0
       (.C(clk),
        .CE(1'b1),
        .D(g_skew_b_r_n_0),
        .Q(g_skew_b_r_0_n_0),
        .R(pe_rst));
  FDRE g_skew_b_r_1
       (.C(clk),
        .CE(1'b1),
        .D(g_skew_b_r_0_n_0),
        .Q(g_skew_b_r_1_n_0),
        .R(pe_rst));
  FDRE g_skew_b_r_2
       (.C(clk),
        .CE(1'b1),
        .D(g_skew_b_r_1_n_0),
        .Q(g_skew_b_r_2_n_0),
        .R(pe_rst));
  FDRE g_skew_b_r_3
       (.C(clk),
        .CE(1'b1),
        .D(g_skew_b_r_2_n_0),
        .Q(g_skew_b_r_3_n_0),
        .R(pe_rst));
  LUT3 #(
    .INIT(8'hD0)) 
    \k_reg[10]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(start),
        .O(start_ok));
  FDRE \k_reg_reg[0] 
       (.C(clk),
        .CE(start_ok),
        .D(k_len[0]),
        .Q(k_reg[0]),
        .R(rst));
  FDRE \k_reg_reg[10] 
       (.C(clk),
        .CE(start_ok),
        .D(k_len[10]),
        .Q(k_reg[10]),
        .R(rst));
  FDRE \k_reg_reg[1] 
       (.C(clk),
        .CE(start_ok),
        .D(k_len[1]),
        .Q(k_reg[1]),
        .R(rst));
  FDRE \k_reg_reg[2] 
       (.C(clk),
        .CE(start_ok),
        .D(k_len[2]),
        .Q(k_reg[2]),
        .R(rst));
  FDRE \k_reg_reg[3] 
       (.C(clk),
        .CE(start_ok),
        .D(k_len[3]),
        .Q(k_reg[3]),
        .R(rst));
  FDRE \k_reg_reg[4] 
       (.C(clk),
        .CE(start_ok),
        .D(k_len[4]),
        .Q(k_reg[4]),
        .R(rst));
  FDRE \k_reg_reg[5] 
       (.C(clk),
        .CE(start_ok),
        .D(k_len[5]),
        .Q(k_reg[5]),
        .R(rst));
  FDRE \k_reg_reg[6] 
       (.C(clk),
        .CE(start_ok),
        .D(k_len[6]),
        .Q(k_reg[6]),
        .R(rst));
  FDRE \k_reg_reg[7] 
       (.C(clk),
        .CE(start_ok),
        .D(k_len[7]),
        .Q(k_reg[7]),
        .R(rst));
  FDRE \k_reg_reg[8] 
       (.C(clk),
        .CE(start_ok),
        .D(k_len[8]),
        .Q(k_reg[8]),
        .R(rst));
  FDRE \k_reg_reg[9] 
       (.C(clk),
        .CE(start_ok),
        .D(k_len[9]),
        .Q(k_reg[9]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \kcnt[0]_i_1 
       (.I0(kcnt_reg[0]),
        .O(\kcnt[0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h00200000)) 
    \kcnt[10]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .O(kcnt));
  LUT6 #(
    .INIT(64'h6AAAAAAAAAAAAAAA)) 
    \kcnt[10]_i_2 
       (.I0(kcnt_reg[10]),
        .I1(kcnt_reg[8]),
        .I2(kcnt_reg[7]),
        .I3(kcnt_reg[6]),
        .I4(\kcnt[10]_i_3_n_0 ),
        .I5(kcnt_reg[9]),
        .O(p_0_in__0[10]));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \kcnt[10]_i_3 
       (.I0(kcnt_reg[5]),
        .I1(kcnt_reg[4]),
        .I2(kcnt_reg[2]),
        .I3(kcnt_reg[1]),
        .I4(kcnt_reg[0]),
        .I5(kcnt_reg[3]),
        .O(\kcnt[10]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \kcnt[1]_i_1 
       (.I0(kcnt_reg[1]),
        .I1(kcnt_reg[0]),
        .O(p_0_in__0[1]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \kcnt[2]_i_1 
       (.I0(kcnt_reg[2]),
        .I1(kcnt_reg[1]),
        .I2(kcnt_reg[0]),
        .O(p_0_in__0[2]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h6AAA)) 
    \kcnt[3]_i_1 
       (.I0(kcnt_reg[3]),
        .I1(kcnt_reg[0]),
        .I2(kcnt_reg[1]),
        .I3(kcnt_reg[2]),
        .O(p_0_in__0[3]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h6AAAAAAA)) 
    \kcnt[4]_i_1 
       (.I0(kcnt_reg[4]),
        .I1(kcnt_reg[2]),
        .I2(kcnt_reg[1]),
        .I3(kcnt_reg[0]),
        .I4(kcnt_reg[3]),
        .O(p_0_in__0[4]));
  LUT6 #(
    .INIT(64'h6AAAAAAAAAAAAAAA)) 
    \kcnt[5]_i_1 
       (.I0(kcnt_reg[5]),
        .I1(kcnt_reg[4]),
        .I2(kcnt_reg[2]),
        .I3(kcnt_reg[1]),
        .I4(kcnt_reg[0]),
        .I5(kcnt_reg[3]),
        .O(\kcnt[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'h9A)) 
    \kcnt[6]_i_1 
       (.I0(kcnt_reg[6]),
        .I1(\kcnt[9]_i_2_n_0 ),
        .I2(kcnt_reg[5]),
        .O(p_0_in__0[6]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'hA6AA)) 
    \kcnt[7]_i_1 
       (.I0(kcnt_reg[7]),
        .I1(kcnt_reg[5]),
        .I2(\kcnt[9]_i_2_n_0 ),
        .I3(kcnt_reg[6]),
        .O(\kcnt[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'hAA6AAAAA)) 
    \kcnt[8]_i_1 
       (.I0(kcnt_reg[8]),
        .I1(kcnt_reg[7]),
        .I2(kcnt_reg[6]),
        .I3(\kcnt[9]_i_2_n_0 ),
        .I4(kcnt_reg[5]),
        .O(\kcnt[8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA6AAAAAAAAAAAAAA)) 
    \kcnt[9]_i_1 
       (.I0(kcnt_reg[9]),
        .I1(kcnt_reg[5]),
        .I2(\kcnt[9]_i_2_n_0 ),
        .I3(kcnt_reg[6]),
        .I4(kcnt_reg[7]),
        .I5(kcnt_reg[8]),
        .O(p_0_in__0[9]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h7FFFFFFF)) 
    \kcnt[9]_i_2 
       (.I0(kcnt_reg[3]),
        .I1(kcnt_reg[0]),
        .I2(kcnt_reg[1]),
        .I3(kcnt_reg[2]),
        .I4(kcnt_reg[4]),
        .O(\kcnt[9]_i_2_n_0 ));
  FDRE \kcnt_reg[0] 
       (.C(clk),
        .CE(kcnt),
        .D(\kcnt[0]_i_1_n_0 ),
        .Q(kcnt_reg[0]),
        .R(pe_rst));
  FDRE \kcnt_reg[10] 
       (.C(clk),
        .CE(kcnt),
        .D(p_0_in__0[10]),
        .Q(kcnt_reg[10]),
        .R(pe_rst));
  FDRE \kcnt_reg[1] 
       (.C(clk),
        .CE(kcnt),
        .D(p_0_in__0[1]),
        .Q(kcnt_reg[1]),
        .R(pe_rst));
  FDRE \kcnt_reg[2] 
       (.C(clk),
        .CE(kcnt),
        .D(p_0_in__0[2]),
        .Q(kcnt_reg[2]),
        .R(pe_rst));
  FDRE \kcnt_reg[3] 
       (.C(clk),
        .CE(kcnt),
        .D(p_0_in__0[3]),
        .Q(kcnt_reg[3]),
        .R(pe_rst));
  FDRE \kcnt_reg[4] 
       (.C(clk),
        .CE(kcnt),
        .D(p_0_in__0[4]),
        .Q(kcnt_reg[4]),
        .R(pe_rst));
  FDRE \kcnt_reg[5] 
       (.C(clk),
        .CE(kcnt),
        .D(\kcnt[5]_i_1_n_0 ),
        .Q(kcnt_reg[5]),
        .R(pe_rst));
  FDRE \kcnt_reg[6] 
       (.C(clk),
        .CE(kcnt),
        .D(p_0_in__0[6]),
        .Q(kcnt_reg[6]),
        .R(pe_rst));
  FDRE \kcnt_reg[7] 
       (.C(clk),
        .CE(kcnt),
        .D(\kcnt[7]_i_1_n_0 ),
        .Q(kcnt_reg[7]),
        .R(pe_rst));
  FDRE \kcnt_reg[8] 
       (.C(clk),
        .CE(kcnt),
        .D(\kcnt[8]_i_1_n_0 ),
        .Q(kcnt_reg[8]),
        .R(pe_rst));
  FDRE \kcnt_reg[9] 
       (.C(clk),
        .CE(kcnt),
        .D(p_0_in__0[9]),
        .Q(kcnt_reg[9]),
        .R(pe_rst));
  LUT6 #(
    .INIT(64'hFF20FF00FF00FF00)) 
    last_seen_i_1
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(in_ok0),
        .I3(last_seen),
        .I4(in_valid),
        .I5(last_seen0),
        .O(last_seen_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT2 #(
    .INIT(4'h6)) 
    last_seen_i_10
       (.I0(kcnt_reg[5]),
        .I1(k_reg[5]),
        .O(last_seen_i_10_n_0));
  LUT3 #(
    .INIT(8'hFE)) 
    last_seen_i_11
       (.I0(k_reg[2]),
        .I1(k_reg[1]),
        .I2(k_reg[0]),
        .O(last_seen_i_11_n_0));
  LUT5 #(
    .INIT(32'h06909009)) 
    last_seen_i_3
       (.I0(k_reg[10]),
        .I1(kcnt_reg[10]),
        .I2(k_reg[9]),
        .I3(last_seen_i_7_n_0),
        .I4(kcnt_reg[9]),
        .O(last_seen_i_3_n_0));
  LUT6 #(
    .INIT(64'h8200008220040820)) 
    last_seen_i_4
       (.I0(last_seen_i_8_n_0),
        .I1(kcnt_reg[6]),
        .I2(k_reg[6]),
        .I3(k_reg[7]),
        .I4(kcnt_reg[7]),
        .I5(last_seen_i_9_n_0),
        .O(last_seen_i_4_n_0));
  LUT6 #(
    .INIT(64'h2100100800210210)) 
    last_seen_i_5
       (.I0(kcnt_reg[3]),
        .I1(last_seen_i_10_n_0),
        .I2(k_reg[3]),
        .I3(k_reg[4]),
        .I4(last_seen_i_11_n_0),
        .I5(kcnt_reg[4]),
        .O(last_seen_i_5_n_0));
  LUT6 #(
    .INIT(64'h4024020002004024)) 
    last_seen_i_6
       (.I0(kcnt_reg[0]),
        .I1(k_reg[0]),
        .I2(k_reg[1]),
        .I3(kcnt_reg[1]),
        .I4(k_reg[2]),
        .I5(kcnt_reg[2]),
        .O(last_seen_i_6_n_0));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    last_seen_i_7
       (.I0(k_reg[8]),
        .I1(k_reg[6]),
        .I2(k_reg[7]),
        .I3(last_seen_i_9_n_0),
        .O(last_seen_i_7_n_0));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'h9)) 
    last_seen_i_8
       (.I0(kcnt_reg[8]),
        .I1(k_reg[8]),
        .O(last_seen_i_8_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    last_seen_i_9
       (.I0(k_reg[5]),
        .I1(k_reg[3]),
        .I2(k_reg[4]),
        .I3(k_reg[2]),
        .I4(k_reg[1]),
        .I5(k_reg[0]),
        .O(last_seen_i_9_n_0));
  FDRE last_seen_reg
       (.C(clk),
        .CE(1'b1),
        .D(last_seen_i_1_n_0),
        .Q(last_seen),
        .R(pe_rst));
  CARRY4 last_seen_reg_i_2
       (.CI(1'b0),
        .CO({last_seen0,last_seen_reg_i_2_n_1,last_seen_reg_i_2_n_2,last_seen_reg_i_2_n_3}),
        .CYINIT(1'b1),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_last_seen_reg_i_2_O_UNCONNECTED[3:0]),
        .S({last_seen_i_3_n_0,last_seen_i_4_n_0,last_seen_i_5_n_0,last_seen_i_6_n_0}));
  LUT6 #(
    .INIT(64'h00000000DFFF8AAA)) 
    \state[0]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(last_seen),
        .I3(done_i_2_n_0),
        .I4(start),
        .I5(rst),
        .O(\state[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h000000002000ECCC)) 
    \state[1]_i_1 
       (.I0(\state_reg_n_0_[0] ),
        .I1(\state_reg_n_0_[1] ),
        .I2(last_seen),
        .I3(done_i_2_n_0),
        .I4(start),
        .I5(rst),
        .O(\state[1]_i_1_n_0 ));
  FDRE \state_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\state[0]_i_1_n_0 ),
        .Q(\state_reg_n_0_[0] ),
        .R(1'b0));
  FDRE \state_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\state[1]_i_1_n_0 ),
        .Q(\state_reg_n_0_[1] ),
        .R(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
