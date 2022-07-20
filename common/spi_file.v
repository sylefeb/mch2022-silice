// This is directly derived from the wrapper by @Mecrisp, see in particular:
//   https://github.com/badgeteam/mch2022-firmware-ice40/blob/master/projects/RISCV-Playground/rtl/riscv_playground.v
// The main building blocks are provided in the badge respository:
//   https://github.com/badgeteam/mch2022-firmware-ice40

module spi_file(
    // pins
    input  spi_mosi,   output spi_miso,
    input  spi_cs_n,   input  spi_clk,
    output irq_n,
    input  clk,        input  resetq,
    // input request
    output        file_request_ready,
    input         file_request_valid,
    input  [31:0] file_request_offset,
    // received data
    output [7:0]  file_data,
    output        file_data_avail
);

    /***************************************************************************/
    // SPI interface.
    /***************************************************************************/

    wire [7:0] usr_miso_data, usr_mosi_data;
    wire usr_mosi_stb, usr_miso_ack;
    wire csn_state, csn_rise, csn_fall;

    spi_dev_core _communication (

        .clk (clk),
        .rst (resetq),

        .usr_mosi_data (usr_mosi_data),
        .usr_mosi_stb  (usr_mosi_stb),
        .usr_miso_data (usr_miso_data),
        .usr_miso_ack  (usr_miso_ack),

        .csn_state (csn_state),
        .csn_rise  (csn_rise),
        .csn_fall  (csn_fall),

        // Interface to SPI wires

        .spi_miso (spi_miso),
        .spi_mosi (spi_mosi),
        .spi_clk  (spi_clk),
        .spi_cs_n (spi_cs_n)
    );

    wire [7:0] pw_wdata;
    wire pw_wcmd, pw_wstb, pw_end;

    wire [7:0] pw_rdata;
    wire pw_req, pw_rstb, pw_gnt;

    wire [3:0] pw_irq;
    wire irq;

    spi_dev_proto _protocol (
        .clk (clk),
        .rst (resetq),

        // Connection to the actual SPI module:

        .usr_mosi_data (usr_mosi_data),
        .usr_mosi_stb  (usr_mosi_stb),
        .usr_miso_data (usr_miso_data),
        .usr_miso_ack  (usr_miso_ack),

        .csn_state (csn_state),
        .csn_rise  (csn_rise),
        .csn_fall  (csn_fall),

        // These wires deliver received data:

        .pw_wdata (pw_wdata),
        .pw_wcmd  (pw_wcmd),
        .pw_wstb  (pw_wstb),
        .pw_end   (pw_end),

        // Replies and requests

        .pw_req   (pw_req),
        .pw_gnt   (pw_gnt),
        .pw_rdata (pw_rdata),
        .pw_rstb  (pw_rstb),

        .pw_irq   (pw_irq),
        .irq      (irq)
    );

    assign pw_irq[3:1] = 3'b000;
    assign irq_n = irq ? 1'b0 : 1'bz;

    /***************************************************************************/
    // File request interface over SPI.
    /***************************************************************************/

    spi_dev_fread #(
        .INTERFACE("STREAM")
    ) _fread (
        .clk (clk),
        .rst (resetq),

        // SPI interface
        .pw_wdata     (pw_wdata),
        .pw_wcmd      (pw_wcmd),
        .pw_wstb      (pw_wstb),
        .pw_end       (pw_end),
        .pw_req       (pw_req),
        .pw_gnt       (pw_gnt),
        .pw_rdata     (pw_rdata),
        .pw_rstb      (pw_rstb),
        .pw_irq       (pw_irq[0]),

        // Read request interface
        .req_file_id  (32'hBFBFBFBF),
        .req_offset   (file_request_offset),
        .req_len      (10'd1023), // One less than the actual requested length!

        .req_valid    (file_request_valid),
        .req_ready    (file_request_ready),

        // Stream reply interface
        .resp_data    (file_data),
        .resp_valid   (file_data_avail)
    );

endmodule
