//1280x720p @ 60 fps over HDMI
`timescale 1ns / 1ps
module top(
    input clk125,
    output tmds_tx_clk_p,
    output tmds_tx_clk_n,
    output [2:0] tmds_tx_data_p,
    output [2:0] tmds_tx_data_n
    );

localparam TIMER = 75000000*2; // 2 sec @ 75 MHz
wire pixel_clk;
wire serdes_clk;
wire rst;
reg [7:0] rstcnt;
wire locked;

wire hsync, hblank, vsync, vblank, active, fsync;

wire [1:0] ctl [0:2];
wire [7:0] pdata [0:2];
wire [9:0] tmds_data [0:2];

integer count;
reg [1:0] sw;

mmcm_0 mmcm_0_inst (
    .clk_in1(clk125),
    .clk_out1(pixel_clk),
    .clk_out2(serdes_clk),
    .locked(locked)
);

always @(posedge pixel_clk or negedge locked) begin
    if(~locked) begin
        rstcnt <= 0;
    end
    else begin
        if(rstcnt != 8'hff) begin
            rstcnt <= rstcnt + 1;
        end
    end
end

assign rst = (rstcnt == 8'hff) ? 1'b0 : 1'b1;

video_timing video_timing_inst(
    .clk(pixel_clk),
    .clken(1'b1),
    .gen_clken(1'b1),
    .sof_state(1'b0),
    .hsync_out(hsync),
    .hblank_out(hblank),
    .vsync_out(vsync),
    .vblank_out(vblank),
    .active_video_out(active),
    .resetn(~rst),
    .fsync_out(fsync)
);

always @(posedge pixel_clk)begin
    if(rst) begin
        count <= 0;
        sw <= 2'b00;
    end
    else begin
        if(count < TIMER-1) begin
            count <= count + 1;
        end
        else begin
            count <= 0;
            if(sw == 2'b11) begin
                sw <= 2'b01;
            end 
            else begin
                sw <= sw + 1;
            end
        end
    end
end

assign pdata[2] = (sw == 2'b01) ? 8'hff : 8'h00;
assign pdata[1] = (sw == 2'b10) ? 8'hff : 8'h00;
assign pdata[0] = (sw == 2'b11) ? 8'hff : 8'h00;

assign ctl[0] = {vsync, hsync};
assign ctl[1] = 2'b00;
assign ctl[2] = 2'b00;

generate
    genvar i;
    for (i=0; i<3; i=i+1) begin
        tmds_encode tmds_encode_inst (
            .pixel_clk(pixel_clk),
            .rst(rst),
            .ctl(ctl[i]),
            .active(active),
            .pdata(pdata[i]),
            .tmds_data(tmds_data[i])
        );
        tmds_oserdes tmds_oserdes_inst(
            .pixel_clk(pixel_clk),
            .serdes_clk(serdes_clk),
            .rst(rst),
            .tmds_data(tmds_data[i]),
            .tmds_serdes_p(tmds_tx_data_p[i]),
            .tmds_serdes_n(tmds_tx_data_n[i])
        );
    end
endgenerate

tmds_oserdes tmds_oserdes_clock(
    .pixel_clk(pixel_clk),
    .serdes_clk(serdes_clk),
    .rst(rst),
    .tmds_data(10'b1111100000),
    .tmds_serdes_p(tmds_tx_clk_p),
    .tmds_serdes_n(tmds_tx_clk_n)
);
endmodule
