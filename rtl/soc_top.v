module soc_top (
    input  clk,
    input  rst_n,
    input  rx,
    output tx
);

wire [7:0] uart_data;
wire uart_start;
wire uart_busy;
wire [7:0] rx_data;
wire rx_valid;

riscv_core core (
    .clk (clk),
    .rst_n (rst_n),
    .uart_data (uart_data),
    .uart_start(uart_start)
);

uart_tx uart_tx_inst (
    .clk (clk),
    .rst_n (rst_n),
    .start (uart_start),
    .data_in(uart_data),
    .tx (tx),
    .busy (uart_busy)
);

uart_rx uart_rx_inst (
    .clk (clk),
    .rst_n (rst_n),
    .rx (rx),
    .data_out(rx_data),
    .valid (rx_valid)
);

endmodule