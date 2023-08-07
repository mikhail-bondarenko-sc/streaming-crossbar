`timescale 1ns / 1ps

// в коде используется сигнал reset и заявлены FSM, но нигде не используется clock, регистры нельзя описать с помощью только комбиноционной логики 
// использование reset в комбинационном always блоке запрещено
// в чем разница между блокирующим (=) и не блокирующим(<=) присваиваниями?
// Нельзя написать без памяти честный арбитраж, нельзя сделать автомат
// 

module round_robin
	#(  parameter   T_DATA_WIDTH = 8,
        parameter   S_DATA_COUNT = 5,
        parameter   M_DATA_COUNT = 3,
        parameter   T_ID___WIDTH = $clog2(S_DATA_COUNT),
        parameter   T_DEST_WIDTH = $clog2(M_DATA_COUNT)
	)
	(	input rst,
		input [S_DATA_COUNT - 1 : 0] request_mask_i,
		input [S_DATA_COUNT - 1 : 0] s_last_i,

		output reg [S_DATA_COUNT - 1 : 0] grant_o, 
		output reg m_last_o,
		output [T_ID___WIDTH - 1 : 0] m_id_o,
		output reg m_valid_o
    );

	reg [T_ID___WIDTH - 1:0] state;
	reg first_one;

	always @ (*) begin: next_grant
		integer i;

		first_one = 0; // ноль в данном случае явлется 32-битным int, а не однобитовым сигналом
		grant_o = 0;
		m_valid_o = 0;

		if(rst) begin
			state = 0;
			m_last_o = 0;
			first_one = 0;
			grant_o = 0;
			
		end else begin
			if(m_last_o) begin
				m_last_o = 0;  // комбинационная петля?
				if(state == S_DATA_COUNT - 1) begin
					state = 0;
				end	else begin
					state = state + 1; // state просто крутится по кругу? а если нет запроса в такте? производительность
				end
			end
			
			if(m_valid_o) m_valid_o = 0; // комбинационная петля?
                                   // m_valid_o после того как установится — обязательно падает в ноль? потоковой передачи нет?

			for (i = 0; i < S_DATA_COUNT; i = i + 1) begin
				if (request_mask_i[(state + i) % S_DATA_COUNT] && !first_one) begin // является ли операция % синтезируемой?
					grant_o[(state + i) % S_DATA_COUNT] = 1'b1;
					first_one = 1; // единица в данном случае явлется 32-битным int, а не однобитовым сигналом
					m_valid_o = 1;
					if (s_last_i[(state + i) % S_DATA_COUNT]) m_last_o = 1; // m_last_o будет назначен, а если условие if (request_mask_i[(state + i) % S_DATA_COUNT] && !first_one) не сработает, что будет с m_last_o?
                                                                  // Мы пишем схемы определенные, не оставляем неопределенности
					state = (state + i) % S_DATA_COUNT;
				end else begin
					grant_o[(state + i) % S_DATA_COUNT] = 1'b0;
				end
			end

		end
	end

	assign m_id_o = state;

endmodule
