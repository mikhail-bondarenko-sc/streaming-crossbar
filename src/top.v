`timescale 1ns / 1ps

module top
    #(  parameter   T_DATA_WIDTH = 8,
        parameter   S_DATA_COUNT = 2,
        parameter   M_DATA_COUNT = 2,
        parameter   T_ID___WIDTH = $clog2(S_DATA_COUNT),
        parameter   T_DEST_WIDTH = $clog2(M_DATA_COUNT)) (
        
        input rst_n,

        input [(T_DATA_WIDTH) * (S_DATA_COUNT) - 1 : 0] s_data_i,
        input [(T_DEST_WIDTH) * (S_DATA_COUNT) - 1 : 0] s_dest_i,
        input [S_DATA_COUNT - 1 : 0] s_last_i,
        input [S_DATA_COUNT - 1 : 0] s_valid_i,
        output [S_DATA_COUNT - 1 : 0] s_ready_o,

        output [(T_DATA_WIDTH) * (M_DATA_COUNT) - 1 : 0] m_data_o,
        output [(T_ID___WIDTH) * (M_DATA_COUNT) - 1 : 0] m_id_o,
        output [M_DATA_COUNT - 1 : 0] m_last_o,
        output [M_DATA_COUNT - 1 : 0] m_valid_o,
        input [M_DATA_COUNT - 1 : 0] m_ready_i
    );

    wire [S_DATA_COUNT * M_DATA_COUNT - 1 : 0] grant;

    schedule # (
        .T_DATA_WIDTH(T_DATA_WIDTH),
        .S_DATA_COUNT(S_DATA_COUNT),
        .M_DATA_COUNT(M_DATA_COUNT),
        .T_ID___WIDTH(T_ID___WIDTH),
        .T_DEST_WIDTH(T_DEST_WIDTH)
    ) schedule(
        .rst(rst_n),

        .s_dest_i(s_dest_i),
        .s_valid_i(s_valid_i),
        .m_ready_i(m_ready_i),
        .s_last_i(s_last_i),

        .m_id_o(m_id_o),
        .m_last_o(m_last_o),
        .m_valid_o(m_valid_o),
        .s_ready_o(s_ready_o),
        .grant_o(grant)
    );

    crossbar # (
        .T_DATA_WIDTH(T_DATA_WIDTH),
        .S_DATA_COUNT(S_DATA_COUNT),
        .M_DATA_COUNT(M_DATA_COUNT),
        .T_ID___WIDTH(T_ID___WIDTH),
        .T_DEST_WIDTH(T_DEST_WIDTH)
    ) crossbar(
        .rst(rst_n),

        .grant_i(grant),
        .s_data_i(s_data_i),

        .m_data_o(m_data_o)
    );





endmodule