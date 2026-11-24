// uret_ln_vektor.py tarafindan uretildi; elle duzenlemeyin
localparam LN_SAYISI = 4;
function [39:0] ln_eps; input integer i; begin case (i)
        0: ln_eps = 40'd1;
        1: ln_eps = 40'd1;
        2: ln_eps = 40'd1;
        3: ln_eps = 40'd1;
        default: ln_eps = 40'd0; endcase end endfunction
function [30:0] ln_m0; input integer i; begin case (i)
        0: ln_m0 = 31'd655931401;
        1: ln_m0 = 31'd638004798;
        2: ln_m0 = 31'd871216554;
        3: ln_m0 = 31'd683654168;
        default: ln_m0 = 31'd0; endcase end endfunction
function [5:0] ln_n; input integer i; begin case (i)
        0: ln_n = 6'd50;
        1: ln_n = 6'd49;
        2: ln_n = 6'd49;
        3: ln_n = 6'd49;
        default: ln_n = 6'd0; endcase end endfunction
function [30:0] ln_x_m0; input integer i; begin case (i)
        0: ln_x_m0 = 31'd863060790;
        1: ln_x_m0 = 31'd1023211101;
        2: ln_x_m0 = 31'd648228509;
        3: ln_x_m0 = 31'd914724452;
        default: ln_x_m0 = 31'd0; endcase end endfunction
function [5:0] ln_x_n; input integer i; begin case (i)
        0: ln_x_n = 6'd26;
        1: ln_x_n = 6'd27;
        2: ln_x_n = 6'd26;
        3: ln_x_n = 6'd26;
        default: ln_x_n = 6'd0; endcase end endfunction
function [30:0] ln_a_m0; input integer i; begin case (i)
        0: ln_a_m0 = 31'd701167798;
        1: ln_a_m0 = 31'd606554150;
        2: ln_a_m0 = 31'd938729158;
        3: ln_a_m0 = 31'd677810651;
        default: ln_a_m0 = 31'd0; endcase end endfunction
function [5:0] ln_a_n; input integer i; begin case (i)
        0: ln_a_n = 6'd26;
        1: ln_a_n = 6'd26;
        2: ln_a_n = 6'd26;
        3: ln_a_n = 6'd26;
        default: ln_a_n = 6'd0; endcase end endfunction
function [30:0] ln_o_m0; input integer i; begin case (i)
        0: ln_o_m0 = 31'd1050081950;
        1: ln_o_m0 = 31'd1070038561;
        2: ln_o_m0 = 31'd546040382;
        3: ln_o_m0 = 31'd738176766;
        default: ln_o_m0 = 31'd0; endcase end endfunction
function [5:0] ln_o_n; input integer i; begin case (i)
        0: ln_o_n = 6'd30;
        1: ln_o_n = 6'd30;
        2: ln_o_n = 6'd29;
        3: ln_o_n = 6'd29;
        default: ln_o_n = 6'd0; endcase end endfunction
function [0:0] ln_yalniz_ilk_token; input integer i; begin case (i)
        0: ln_yalniz_ilk_token = 1'd0;
        1: ln_yalniz_ilk_token = 1'd0;
        2: ln_yalniz_ilk_token = 1'd0;
        3: ln_yalniz_ilk_token = 1'd1;
        default: ln_yalniz_ilk_token = 1'd0; endcase end endfunction
