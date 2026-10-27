// -----------------------------------------------------------------------------
// bolucu_seri.v -- isaretsiz ardisik (restoring) bolucu: W bit / W bit, 1 bit/cevrim (G11)
// start (1 cevrim) ile num/den alinir; W cevrim sonra done=1 (1 cevrim), quo/rem tutulur.
// den = 0 verilmez (cagiran garanti eder).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module bolucu_seri #(
    parameter W = 32
) (
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [W-1:0] num,
    input  wire [W-1:0] den,
    output reg          busy,
    output reg          done,
    output reg  [W-1:0] quo,
    output reg  [W-1:0] rem
);
    reg [W-1:0] n_sh;        // bolunen, soldan bit cikar
    reg [W-1:0] d_reg;
    reg [W:0]   r;
    reg [7:0]   say;

    wire [W:0] r_kay  = {r[W-1:0], n_sh[W-1]};
    wire       ge     = (r_kay >= {1'b0, d_reg});
    wire [W:0] r_yeni = ge ? (r_kay - {1'b0, d_reg}) : r_kay;

    always @(posedge clk) begin
        if (rst) begin
            busy <= 1'b0; done <= 1'b0; quo <= {W{1'b0}}; rem <= {W{1'b0}};
            n_sh <= {W{1'b0}}; d_reg <= {W{1'b0}}; r <= {(W+1){1'b0}}; say <= 8'd0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                busy <= 1'b1; n_sh <= num; d_reg <= den; r <= {(W+1){1'b0}}; quo <= {W{1'b0}}; say <= 8'd0;
            end else if (busy) begin
                r    <= r_yeni;
                n_sh <= {n_sh[W-2:0], 1'b0};
                quo  <= {quo[W-2:0], ge};
                say  <= say + 8'd1;
                if (say == W - 1) begin
                    busy <= 1'b0; done <= 1'b1;
                    rem  <= r_yeni[W-1:0];
                    quo  <= {quo[W-2:0], ge};
                end
            end
        end
    end
endmodule
