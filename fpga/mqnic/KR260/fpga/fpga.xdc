# XDC constraints for the Xilinx KR260 board
# part: xck26-sfvc784-2LV-c

# General configuration
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]

# LEDs
set_property -dict {LOC F8   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[0]}] ;# HPA14P som240_1_d13
set_property -dict {LOC E8   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[1]}] ;# HPA14N som240_1_d14

set_property -dict {LOC G8   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {sfp_led[0]}] ;# HPA13P som240_1_a12
set_property -dict {LOC F7   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {sfp_led[1]}] ;# HPA13N som240_1_a13

set_false_path -to [get_ports {led[*] sfp_led[*]}]
set_output_delay 0 [get_ports {led[*] sfp_led[*]}]

# SFP+ Interface
set_property -dict {LOC T2  } [get_ports sfp_rx_p] ;# MGTHRXP2_224 GTHE4_CHANNEL_X1Y12 / GTHE4_COMMON_X1Y3
set_property -dict {LOC T1  } [get_ports sfp_rx_n] ;# MGTHRXN2_224 GTHE4_CHANNEL_X1Y12 / GTHE4_COMMON_X1Y3
set_property -dict {LOC R4  } [get_ports sfp_tx_p] ;# MGTHTXP2_224 GTHE4_CHANNEL_X1Y12 / GTHE4_COMMON_X1Y3
set_property -dict {LOC R3  } [get_ports sfp_tx_n] ;# MGTHTXN2_224 GTHE4_CHANNEL_X1Y12 / GTHE4_COMMON_X1Y3
set_property -dict {LOC Y6  } [get_ports sfp_mgt_refclk_p] ;# MGTREFCLK0P_224 from U90
set_property -dict {LOC Y5  } [get_ports sfp_mgt_refclk_n] ;# MGTREFCLK0N_224 from U90
set_property -dict {LOC Y10  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports sfp_tx_disable] ;# HDB19 som240_2_a47
set_property -dict {LOC A10  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports sfp_tx_fault]   ;# HDA19 som240_1_c23
set_property -dict {LOC J12  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports sfp_rx_los]     ;# HDA10 som240_1_a16
set_property -dict {LOC W10  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports sfp_mod_abs]    ;# HDB18 som240_2_a46
set_property -dict {LOC AB11 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports sfp_i2c_scl]    ;# HDB16 som240_2_b49
set_property -dict {LOC AC11 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports sfp_i2c_sda]    ;# HDB17 som240_2_b50

# 156.25 MHz MGT reference clock
create_clock -period 6.400 -name sfp_mgt_refclk [get_ports sfp_mgt_refclk_p]

set_false_path -to [get_ports {sfp_tx_disable}]
set_output_delay 0 [get_ports {sfp_tx_disable}]
set_false_path -from [get_ports {sfp_tx_fault sfp_rx_los sfp_mod_abs}]
set_input_delay 0 [get_ports {sfp_tx_fault sfp_rx_los sfp_mod_abs}]

set_false_path -to [get_ports {sfp_i2c_sda sfp_i2c_scl}]
set_output_delay 0 [get_ports {sfp_i2c_sda sfp_i2c_scl}]
set_false_path -from [get_ports {sfp_i2c_sda sfp_i2c_scl}]
set_input_delay 0 [get_ports {sfp_i2c_sda sfp_i2c_scl}]

# PL Ethernet: PHY2 (U79), J10B, 1 Gbps
# Pin map: https://github.com/fpganinja/taxi/blob/master/src/eth/example/KR260/fpga/syn/phy2.xdc
set_property -dict {LOC D4 IOSTANDARD LVCMOS18} [get_ports rgmii_rx_clk]
set_property -dict {LOC A1 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[0]}]
set_property -dict {LOC B3 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[1]}]
set_property -dict {LOC A3 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[2]}]
set_property -dict {LOC B4 IOSTANDARD LVCMOS18} [get_ports {rgmii_rxd[3]}]
set_property -dict {LOC A4 IOSTANDARD LVCMOS18} [get_ports rgmii_rx_ctl]
set_property -dict {LOC A2 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 12} [get_ports rgmii_tx_clk]
set_property -dict {LOC E1 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 12} [get_ports {rgmii_txd[0]}]
set_property -dict {LOC D1 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 12} [get_ports {rgmii_txd[1]}]
set_property -dict {LOC F2 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 12} [get_ports {rgmii_txd[2]}]
set_property -dict {LOC E2 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 12} [get_ports {rgmii_txd[3]}]
set_property -dict {LOC F1 IOSTANDARD LVCMOS18 SLEW FAST DRIVE 12} [get_ports rgmii_tx_ctl]
set_property -dict {LOC B1 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports rgmii_reset_n]

create_clock -period 8.000 -name rgmii_rx_clk [get_ports rgmii_rx_clk]
set_false_path -to [get_ports rgmii_reset_n]
set_output_delay 0 [get_ports rgmii_reset_n]

# IODELAY_GROUP is already assigned in rtl/rgmii_phy_init.v.
# Keep RX_INPUT_DELAY_PS under RTL control; do not override DELAY_VALUE here.

# External RGMII timing: initial 1 Gbps, PHY RX/TX internal delay disabled.
# The FPGA supplies the TX clock skew with CLKOUT1_PHASE=90 / USE_CLK90=TRUE.
# XDC describes this PHY configuration; it does not program the PHY registers.
# Confirm this mode after reset before treating timing closure as board signoff.
#
# PHY limits: TI DP83867CS, SNLS504G (June 2026), section 6.10:
#   aligned-mode RX output skew: -0.5 to +0.5 ns
#   PHY TX input setup/hold requirement: 1.0 / 1.0 ns
# https://www.ti.com/lit/ds/symlink/dp83867cs.pdf
#
# SoM PCB delays: AMD XilinxBoardStore 2025.2, kr260_som/1.1/part0_pins.xml.
# Worst-case (data delay - clock delay), including all four data bits and CTL:
#   RX: 0.36458-0.44535 = -0.08077; 0.44855-0.36437 = +0.08418 ns
#   TX: 0.39234-0.44671 = -0.05437; 0.48452-0.36549 = +0.11903 ns
# https://github.com/Xilinx/XilinxBoardStore/blob/2025.2/boards/Xilinx/kr260_som/1.1/part0_pins.xml
#
# Carrier-card skew is NOT measured here. Allocate +/-0.1 ns, following the
# example budget in TI SNLA243, section 3.3, and round the bounds outwards.
# This is a design assumption, not a published KR260 carrier-card guarantee.
# https://www.ti.com/lit/an/snla243/snla243.pdf
#   RX limits = PHY skew + SoM skew + carrier skew = [-0.68077, +0.68418]
#   TX PCB limits = SoM skew + carrier skew = [-0.15437, +0.21903]
# Recalculate these limits if the PHY mode or carrier-card budget changes.
# set RX_MIN_NS       -0.69
# set RX_MAX_NS        0.69
# set TX_SETUP_NS      1.0
# set TX_HOLD_NS       1.0
# set PCB_TX_MIN_NS   -0.16
# set PCB_TX_MAX_NS    0.22

# foreach key {RX_MIN_NS RX_MAX_NS TX_SETUP_NS TX_HOLD_NS PCB_TX_MIN_NS PCB_TX_MAX_NS} {
#     if {![info exists $key] || ![string is double -strict [set $key]]} {
#         error "Missing or invalid KR260 RGMII timing value: $key (ns)"
#     }
# }

# Forward the already phase-shifted clock; do not add another 90-degree shift.
create_generated_clock -name rgmii_tx_clk \
    -source [get_pins clk_mmcm_inst/CLKOUT1] \
    -divide_by 1 [get_ports rgmii_tx_clk]

# set rx_ports [get_ports {rgmii_rxd[*] rgmii_rx_ctl}]
# set tx_ports [get_ports {rgmii_txd[*] rgmii_tx_ctl}]

# # External arrival times only; IDELAYE3 is already modelled inside the FPGA.
# set_input_delay -clock rgmii_rx_clk -min $RX_MIN_NS $rx_ports
# set_input_delay -clock rgmii_rx_clk -max $RX_MAX_NS $rx_ports
# set_input_delay -clock rgmii_rx_clk -clock_fall -add_delay \
#     -min $RX_MIN_NS $rx_ports
# set_input_delay -clock rgmii_rx_clk -clock_fall -add_delay \
#     -max $RX_MAX_NS $rx_ports

# set tx_max [expr {$TX_SETUP_NS + $PCB_TX_MAX_NS}]
# set tx_min [expr {-$TX_HOLD_NS + $PCB_TX_MIN_NS}]
# set_output_delay -clock rgmii_tx_clk -max $tx_max $tx_ports
# set_output_delay -clock rgmii_tx_clk -min $tx_min $tx_ports
# set_output_delay -clock rgmii_tx_clk -clock_fall -add_delay \
#     -max $tx_max $tx_ports
# set_output_delay -clock rgmii_tx_clk -clock_fall -add_delay \
#     -min $tx_min $tx_ports

set_property PACKAGE_PIN A12 [get_ports fan_en]
set_property IOSTANDARD LVCMOS33 [get_ports fan_en]
