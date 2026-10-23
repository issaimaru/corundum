// SPDX-License-Identifier: BSD-2-Clause-Views
/**
  * RGMII PHY Initialization : Made by issaimaru
  */

`resetall
`timescale 1ns / 1ps
`default_nettype none

module rgmii_phy_init #(
    parameter RX_INPUT_DELAY_PS = 0
)(
    input  wire       clk_125mhz,
    input  wire       rst_125mhz,
    input  wire       clk_312mhz,
    input  wire       mmcm_locked,
    input  wire [3:0] rgmii_rxd,
    input  wire       rgmii_rx_ctl,
    output wire [3:0] rgmii_rxd_delayed,
    output wire       rgmii_rx_ctl_delayed,
    output wire       eth_rst_125mhz,
    output wire       rgmii_reset_n
);

// 1. Reset the delay controller for 64 reference-clock cycles (204.8 ns).
wire ref_rst;
wire idelay_ready;
reg [5:0] idelay_reset_count = 6'd0;
reg idelay_reset = 1'b1;

sync_reset #(.N(4)) ref_reset_inst (
    .clk(clk_312mhz),
    .rst(!mmcm_locked),
    .out(ref_rst)
);

always @(posedge clk_312mhz or posedge ref_rst) begin
    if (ref_rst) begin
        idelay_reset_count <= 6'd0;
        idelay_reset <= 1'b1;
    end else begin
        if (!(&idelay_reset_count))
            idelay_reset_count <= idelay_reset_count + 1'b1;
        idelay_reset <= !(&idelay_reset_count);
    end
end

(* IODELAY_GROUP = "pl_eth_rx_delay" *)
IDELAYCTRL #(.SIM_DEVICE("ULTRASCALE")) idelayctrl_inst (
    .REFCLK(clk_312mhz),
    .RST(idelay_reset),
    .RDY(idelay_ready)
);

// 2. Delay RXD[3:0] and RX_CTL; the RX clock bypasses these delays.
wire [4:0] rx_raw = {rgmii_rx_ctl, rgmii_rxd};
wire [4:0] rx_delayed;
assign {rgmii_rx_ctl_delayed, rgmii_rxd_delayed} = rx_delayed;

genvar bit_index;
generate
    for (bit_index = 0; bit_index < 5; bit_index = bit_index + 1) begin : rx_delay
        (* IODELAY_GROUP = "pl_eth_rx_delay" *)
        IDELAYE3 #(
            .DELAY_SRC("IDATAIN"),
            .CASCADE("NONE"),
            .DELAY_TYPE("FIXED"),
            .DELAY_FORMAT("TIME"),
            .DELAY_VALUE(RX_INPUT_DELAY_PS),
            .REFCLK_FREQUENCY(312.5),
            .UPDATE_MODE("SYNC"),
            .SIM_DEVICE("ULTRASCALE_PLUS")
        ) idelay_inst (
            .IDATAIN(rx_raw[bit_index]),
            .DATAIN(1'b0),
            .DATAOUT(rx_delayed[bit_index]),
            .CLK(1'b0),
            .EN_VTC(1'b1),
            .CE(1'b0),
            .INC(1'b0),
            .LOAD(1'b0),
            .RST(1'b0),
            .CNTVALUEIN(9'd0),
            .CNTVALUEOUT(),
            .CASC_IN(1'b0),
            .CASC_RETURN(1'b0),
            .CASC_OUT()
        );
    end
endgenerate

// 3. Release the MAC reset after calibration, then hold the PHY for 8.39 ms.
// sync_reset asserts asynchronously and releases on two 125 MHz clock edges.
sync_reset #(.N(2)) mac_reset_inst (
    .clk(clk_125mhz),
    .rst(rst_125mhz || !idelay_ready),
    .out(eth_rst_125mhz)
);

reg [19:0] phy_reset_count = 20'd0;
reg phy_reset_n_reg = 1'b0;
always @(posedge clk_125mhz or posedge eth_rst_125mhz) begin
    if (eth_rst_125mhz) begin
        phy_reset_count <= 20'd0;
        phy_reset_n_reg <= 1'b0;
    end else begin
        if (!(&phy_reset_count))
            phy_reset_count <= phy_reset_count + 1'b1;
        phy_reset_n_reg <= &phy_reset_count;
    end
end

assign rgmii_reset_n = phy_reset_n_reg;

endmodule

`resetall