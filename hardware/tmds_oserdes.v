`timescale 1ns / 1ps
module tmds_oserdes(
    input pixel_clk,
    input serdes_clk,
    input rst,
    input [9:0] tmds_data,
    
    output tmds_serdes_p,
    output tmds_serdes_n
    );
    
wire tmds_serdes_data;
wire shiftout_0, shiftout_1;

OBUFDS #(.IOSTANDARD("TMDS_33")) obufds_tmds(
    .I(tmds_serdes_data),
    .O(tmds_serdes_p),
    .OB(tmds_serdes_n)
);

OSERDESE2 #(
    .DATA_RATE_OQ("DDR"),
    .DATA_RATE_TQ("SDR"),
    .DATA_WIDTH(10),
    .INIT_OQ(1'b0),
    .INIT_TQ(1'b0),
    .SERDES_MODE("MASTER"),
    .SRVAL_OQ(1'b0),
    .SRVAL_TQ(1'b0),
    .TBYTE_CTL("FALSE"),
    .TBYTE_SRC("FALSE"),
    .TRISTATE_WIDTH(1)
) oserdes_primary (
    .OFB(),
    .OQ(tmds_serdes_data),
    .SHIFTOUT1(),
    .SHIFTOUT2(),
    .TBYTEOUT(),
    .TFB(),
    .TQ(),
    .CLK(serdes_clk),
    .CLKDIV(pixel_clk),
    .D1(tmds_data[0]),
    .D2(tmds_data[1]),
    .D3(tmds_data[2]),
    .D4(tmds_data[3]),
    .D5(tmds_data[4]),
    .D6(tmds_data[5]),
    .D7(tmds_data[6]),
    .D8(tmds_data[7]),
    .OCE(1'b1),
    .RST(rst),
    .SHIFTIN1(shiftout_0),
    .SHIFTIN2(shiftout_1),
    .T1(1'b0),
    .T2(1'b0),
    .T3(1'b0),
    .T4(1'b0),
    .TBYTEIN(1'b0),
    .TCE(1'b0)
    );
OSERDESE2 #(
    .DATA_RATE_OQ("DDR"),
    .DATA_RATE_TQ("SDR"),
    .DATA_WIDTH(10),
    .INIT_OQ(1'b0),
    .INIT_TQ(1'b0),
    .SERDES_MODE("SLAVE"),
    .SRVAL_OQ(1'b0),
    .SRVAL_TQ(1'b0),
    .TBYTE_CTL("FALSE"),
    .TBYTE_SRC("FALSE"),
    .TRISTATE_WIDTH(1)
    ) oserdes_secondary (
    .OFB(),
    .OQ(),
    .SHIFTOUT1(shiftout_0),
    .SHIFTOUT2(shiftout_1),
    .TBYTEOUT(),
    .TFB(),
    .TQ(),
    .CLK(serdes_clk),
    .CLKDIV(pixel_clk),
    .D1(1'b0),
    .D2(1'b0),
    .D3(tmds_data[8]),
    .D4(tmds_data[9]),
    .D5(1'b0),
    .D6(1'b0),
    .D7(1'b0),
    .D8(1'b0),
    .OCE(1'b1),
    .RST(rst),
    .SHIFTIN1(1'b0),
    .SHIFTIN2(1'b0),
    .T1(1'b0),
    .T2(1'b0),
    .T3(1'b0),
    .T4(1'b0),
    .TBYTEIN(1'b0),
    .TCE(1'b0)
    );
endmodule
