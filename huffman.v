module huffman(clk, reset, gray_valid, CNT_valid,  gray_data, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
    code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output reg CNT_valid;
output reg [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output reg code_valid;
output reg [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output reg [7:0] M1, M2, M3, M4, M5, M6;
/*---------------------------------------------------*/
reg [7:0] SET[0:5];
reg [5:0] SET_flag[0:5];
reg [2:0] num;
reg [2:0] times;
reg [2:0] count;
reg [6:0] amount; 

reg [2:0] endpoint;
reg [2:0] bitpos[0:5];

reg [2:0] state;
reg [2:0] nextstate;
parameter Initialization = 3'd0;
parameter OutputCNT = 3'd1;
parameter Sort = 3'd2;
parameter Encode = 3'd3;
parameter FinalStage = 3'd4;
parameter Finish = 3'd5;
/*---------------------------------------------------*/

always@(posedge clk or posedge reset) begin
	if(reset) state <= Initialization;
	else state <= nextstate;
end

always@(*) begin
	case(state)
		Initialization: begin
			if(amount==7'd100) nextstate = OutputCNT;
			else nextstate = Initialization;
		end
		
		OutputCNT: nextstate = Sort;
		
		Sort: begin
			if(times==3'd7) nextstate = Encode;
			else nextstate = Sort;
		end
		
		Encode: begin
			if(endpoint==3'd1) nextstate = FinalStage;
			else nextstate = Sort;
		end
		
		FinalStage: nextstate = Finish;
		default: nextstate = Finish;
	endcase
end

always@(posedge clk) begin
	if(reset) begin
		CNT1 <= 8'd0;
		CNT2 <= 8'd0;
		CNT3 <= 8'd0;
		CNT4 <= 8'd0;
		CNT5 <= 8'd0;
		CNT6 <= 8'd0;
		CNT_valid <= 0;
		amount <= 7'd0;
		/*-----------------------*/
		count <= 3'd0;
		num <= 3'd0;
		times <= 3'd0;
		/*-----------------------*/
		SET[0] <= 8'd0;
		SET[1] <= 8'd0;
		SET[2] <= 8'd0;
		SET[3] <= 8'd0;
		SET[4] <= 8'd0;
		SET[5] <= 8'd0;
		SET_flag[0] <= 6'b000001;
		SET_flag[1] <= 6'b000010;
		SET_flag[2] <= 6'b000100;
		SET_flag[3] <= 6'b001000;
		SET_flag[4] <= 6'b010000;
		SET_flag[5] <= 6'b100000;
		endpoint <= 3'd5;
		/*-----------------------*/
		HC1 <= 8'd0;
		HC2 <= 8'd0;
		HC3 <= 8'd0;
		HC4 <= 8'd0;
		HC5 <= 8'd0;
		HC6 <= 8'd0;
		M1 <= 8'd0;
		M2 <= 8'd0;
		M3 <= 8'd0;
		M4 <= 8'd0;
		M5 <= 8'd0;
		M6 <= 8'd0;
		/*-----------------------*/
		bitpos[0] <= 3'd0;
		bitpos[1] <= 3'd0;
		bitpos[2] <= 3'd0;
		bitpos[3] <= 3'd0;
		bitpos[4] <= 3'd0;
		bitpos[5] <= 3'd0;
		code_valid <= 0;
	end
	else begin
		case(state)
			Initialization: begin
				if(gray_valid) begin
					case(gray_data)
						8'h01: CNT1 <= CNT1 + 8'd1;
						8'h02: CNT2 <= CNT2 + 8'd1;
						8'h03: CNT3 <= CNT3 + 8'd1;
						8'h04: CNT4 <= CNT4 + 8'd1;
						8'h05: CNT5 <= CNT5 + 8'd1;
						8'h06: CNT6 <= CNT6 + 8'd1;
					endcase
					amount <= amount + 7'd1;
				end
			end
			
			OutputCNT: begin
				count <= 3'd0;
				num <= 3'd1;
				times <= 3'd2;
				CNT_valid <= 1;
				SET[0] <= CNT1;
				SET[1] <= CNT2;
				SET[2] <= CNT3;
				SET[3] <= CNT4;
				SET[4] <= CNT5;
				SET[5] <= CNT6;			
			end
			
			Sort: begin
				CNT_valid <= 0;
				if(times!=7) begin
					if(SET[num] > SET[count]) begin
						SET[num] <= SET[count];
						SET[count] <= SET[num];
						SET_flag[num] <= SET_flag[count];
						SET_flag[count] <= SET_flag[num];
						if(count!=0) num <= num - 3'd1;
					end

					if(count==3'd0) begin
						num <= times;
						times <= times + 3'd1;
						count <= times - 3'd1;
					end
					else begin
						count <= count - 3'd1;
					end
				end
			end
				
			Encode: begin
				endpoint <= endpoint - 3'd1;
				//the smallest one
				if(SET_flag[endpoint][0]) begin
					M1[bitpos[0]] <= 1;
					HC1[bitpos[0]] <= 1;
					bitpos[0] <= bitpos[0] + 3'd1;
				end
				if(SET_flag[endpoint][1]) begin
					M2[bitpos[1]] <= 1;
					HC2[bitpos[1]] <= 1;
					bitpos[1] <= bitpos[1] + 3'd1;
				end
				if(SET_flag[endpoint][2]) begin
					M3[bitpos[2]] <= 1;
					HC3[bitpos[2]] <= 1;
					bitpos[2] <= bitpos[2] + 3'd1;
				end
				if(SET_flag[endpoint][3]) begin
					M4[bitpos[3]] <= 1;
					HC4[bitpos[3]] <= 1;
					bitpos[3] <= bitpos[3] + 3'd1;
				end
				if(SET_flag[endpoint][4]) begin
					M5[bitpos[4]] <= 1;
					HC5[bitpos[4]] <= 1;
					bitpos[4] <= bitpos[4] + 3'd1;
				end
				if(SET_flag[endpoint][5]) begin
					M6[bitpos[5]] <= 1;
					HC6[bitpos[5]] <= 1;
					bitpos[5] <= bitpos[5] + 3'd1;
				end
				//the second smallest one
				if(SET_flag[endpoint-3'd1][0]) begin
					M1[bitpos[0]] <= 1;
					HC1[bitpos[0]] <= 0;
					bitpos[0] <= bitpos[0] + 3'd1;
				end
				if(SET_flag[endpoint-3'd1][1]) begin
					M2[bitpos[1]] <= 1;
					HC2[bitpos[1]] <= 0;
					bitpos[1] <= bitpos[1] + 3'd1;
				end
				if(SET_flag[endpoint-3'd1][2]) begin
					M3[bitpos[2]] <= 1;
					HC3[bitpos[2]] <= 0;
					bitpos[2] <= bitpos[2] + 3'd1;
				end
				if(SET_flag[endpoint-3'd1][3]) begin
					M4[bitpos[3]] <= 1;
					HC4[bitpos[3]] <= 0;
					bitpos[3] <= bitpos[3] + 3'd1;
				end
				if(SET_flag[endpoint-3'd1][4]) begin
					M5[bitpos[4]] <= 1;
					HC5[bitpos[4]] <= 0;
					bitpos[4] <= bitpos[4] + 3'd1;
				end
				if(SET_flag[endpoint-3'd1][5]) begin
					M6[bitpos[5]] <= 1;
					HC6[bitpos[5]] <= 0;
					bitpos[5] <= bitpos[5] + 3'd1;
				end
				//Operation
				SET[endpoint] <= 8'd0;
				SET_flag[endpoint] <= 6'b000000;
				SET[endpoint-3'd1] <= SET[endpoint] + SET[endpoint-3'd1];
				SET_flag[endpoint-3'd1] <= SET_flag[endpoint] | SET_flag[endpoint-3'd1];
				//Initialization for Sort
				count <= 3'd0;
				num <= 3'd1;
				times <= 3'd2;
			end
			
			FinalStage: code_valid <= 1;
			Finish: code_valid <= 0;
		endcase
	end
end

endmodule

