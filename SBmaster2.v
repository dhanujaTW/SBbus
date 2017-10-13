`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2017 14:05:54
// Design Name: 
// Module Name: SBmaster1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SBmaster2(
 sb_resetn,
 sb_clk,
 
 sb_grant_m2,
 sb_ready_m2,
 sb_resp_m2,
 sb_rdata_m2,
 
 sb_busreq_m2,
 sb_lock_m2,
 sb_trans_m2,
 sb_addr_m2,
 sb_write_m2,
 sb_size_m2,
 sb_burst_m2,
 sb_wdata_m2,
 
 // user interface for testing
  usr_contl_cmd_m2,
  usr_size_m2,
  usr_data_m2,
  usr_num_burst_m2,
  usr_add_m2,
  usr_valid_m2,
  
  usr_send_rdy_m2
    );
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    
//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
 
    localparam                          SB_ADDR_WIDTH         		= 32;                             
    localparam                          SB_TRAS_TYPE          		= 2;
    localparam   					    SB_TRANS_SIZE         		= 3;
    localparam                          SB_BURST_NUM          		= 3;
    localparam                          SB_WDATA_WIDTH        		= 32;
	localparam                          SB_RDATA_WIDTH        		= 32;
	localparam                          SB_RESP_TYPE          		= 2;
	localparam               			RESP_STATE_WIDTH 	  		= 2;
	localparam [RESP_STATE_WIDTH-1:0] 	SPLIT  				  		= 3;
	localparam [RESP_STATE_WIDTH-1:0] 	OKAY   						= 1;
	localparam [RESP_STATE_WIDTH-1:0] 	ERROR  						= 2;


    
	localparam [SB_BURST_NUM-1:0]      	INCR		              	= 1;
	
	localparam [RESP_STATE_WIDTH-1:0] 	IDLE   						= 0;
	localparam [RESP_STATE_WIDTH-1:0] 	BUSY   						= 1;
	localparam [RESP_STATE_WIDTH-1:0] 	NONSEQ 						= 2;
	localparam [RESP_STATE_WIDTH-1:0] 	SEQ    						= 3;
	
	localparam 							STATE_WIDTH      		    = 4;
        	
	localparam [STATE_WIDTH-1:0]			STATE_INIT_BUS_REQ 		= 0;
	localparam [STATE_WIDTH-1:0]			STATE_WR_CONTRL    		= 1;   
	localparam [STATE_WIDTH-1:0]			STATE_WR_FINISH    		= 2;
	localparam [STATE_WIDTH-1:0]			STATE_SPLIT_OCCUR  		= 3;
	localparam [STATE_WIDTH-1:0]			STATE_INIT_BUS_RD_REQ 	= 4;
	localparam [STATE_WIDTH-1:0]			STATE_RD_CONTRL			= 5;
	localparam [STATE_WIDTH-1:0]			STATE_RD_DATA			= 6;
	localparam [STATE_WIDTH-1:0]			STATE_RD_FINISH			= 7;
	localparam [STATE_WIDTH-1:0]			STATE_SPLIT_RDOCCUR		= 8;
//------------------------------			---------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------

    input                                   sb_clk;
    input                                   sb_resetn;


    // axi4 stream rx interface (connection to donwstream module)
    input							       sb_grant_m2;
    input               				   sb_ready_m2;
    input       [SB_RESP_TYPE-1:0]         sb_resp_m2;
    input       [SB_RDATA_WIDTH-1:0]       sb_rdata_m2;
	
    output reg     	                       sb_busreq_m2;
    output reg      	   				   sb_lock_m2;
    output reg  [SB_TRAS_TYPE-1:0]  	   sb_trans_m2;
	output reg  [SB_ADDR_WIDTH-1:0] 	   sb_addr_m2;
	output reg                             sb_write_m2;
	output reg  [SB_TRANS_SIZE-1:0]        sb_size_m2;
	output reg  [SB_BURST_NUM-1:0]         sb_burst_m2;
	output reg  [SB_WDATA_WIDTH-1:0]       sb_wdata_m2;   

    input                                  usr_contl_cmd_m2;
	input 		[SB_TRANS_SIZE-1:0]		   usr_size_m2;
	input		[SB_WDATA_WIDTH-1:0]	   usr_data_m2;
	input		[SB_TRANS_SIZE-1:0]        usr_num_burst_m2;
	input 		[SB_ADDR_WIDTH-1:0]        usr_add_m2;
	input                                  usr_valid_m2;
										   
	output reg							   usr_send_rdy_m2;
	//output reg usr_stop;
	
	

	reg [STATE_WIDTH-1:0]                                  wr_state;
	reg [STATE_WIDTH-1:0]                     			   rd_state;
	reg [SB_TRANS_SIZE-1:0]				   beat_counter;
	reg wr_en;
	reg rd_en;
	reg [SB_TRANS_SIZE-1:0]     num_burst;
	reg [SB_TRANS_SIZE-1:0]    current_read_burst;
	reg [SB_RDATA_WIDTH-1:0]	rd_data;
	
	always @(posedge sb_clk)begin
		if(!sb_resetn)begin
			beat_counter <= {SB_TRANS_SIZE*{1'b0}};
			usr_send_rdy_m2 <= 1'b0;
			wr_en <= 1'b0;
			wr_state <= STATE_INIT_BUS_REQ;
			sb_busreq_m2<= {1'b0};
			sb_lock_m2	<= {1'b0};
			sb_trans_m2	<= {SB_TRAS_TYPE*{1'b0}};
			sb_addr_m2	<= {SB_ADDR_WIDTH*{1'b0}};
			sb_write_m2	<= {1'b0};
			sb_size_m2	<= {SB_TRANS_SIZE*{1'b0}};
			sb_burst_m2	<= {SB_BURST_NUM*{1'b0}};
			sb_wdata_m2	<= {SB_WDATA_WIDTH*{1'b0}}; 
			//usr_stop <=1'b0;
		end
		else begin
			wr_en <= usr_contl_cmd_m2;
			if(wr_en && usr_valid_m2) begin
			case(wr_state)
				STATE_INIT_BUS_REQ : begin
					sb_busreq_m2 <= 1'b1;
					if(sb_grant_m2)begin
					wr_state  <= STATE_WR_CONTRL;
					sb_addr_m2	<= usr_add_m2;
					end
					else begin
						wr_state  <= STATE_INIT_BUS_REQ;
					end
				end
				STATE_WR_CONTRL	: begin
					if(sb_ready_m2)begin
						sb_addr_m2	<= usr_add_m2;
						sb_write_m2	<= 1'b1;
						sb_size_m2	<= usr_size_m2;
						sb_burst_m2	<= INCR;
						usr_send_rdy_m2 <= 1'b1;  // indicate the user to send data
						if(beat_counter==3'b0) begin
							sb_wdata_m2	<= usr_data_m2;
							beat_counter<= beat_counter+1;
							wr_state  <= STATE_WR_CONTRL;
						end
						else if(beat_counter < usr_num_burst_m2 && sb_resp_m2==OKAY)begin
							sb_wdata_m2	<= usr_data_m2;
							beat_counter<= beat_counter+1;
							wr_state  <= STATE_WR_CONTRL;
						end	
						else begin
							if(sb_resp_m2==OKAY) begin
								wr_state  <= STATE_WR_FINISH;
							end
							else begin
								wr_state  <= STATE_WR_CONTRL;
								beat_counter <= {SB_TRANS_SIZE*{1'b0}};
							end
						end
						if(beat_counter==3'b0)begin
							sb_trans_m2 <= NONSEQ;
						end
						else begin
							sb_trans_m2 <= SEQ;
						end
					end
					else begin
						if(sb_resp_m2==SPLIT) begin
							wr_state  <= STATE_SPLIT_OCCUR;
						end
						else begin
							wr_state <= STATE_INIT_BUS_REQ;
							beat_counter <= {SB_TRANS_SIZE*{1'b0}};
						end
					end
				end
				STATE_WR_FINISH	: begin
					wr_state  <= STATE_INIT_BUS_REQ;
					sb_trans_m2 <= IDLE;
					beat_counter <= {SB_TRANS_SIZE*{1'b0}};
					sb_busreq_m2 <= 1'b0;
					//usr_stop <=1'b1;
				end
				STATE_SPLIT_OCCUR : begin
					sb_trans_m2 <= IDLE;
					usr_send_rdy_m2 <= 1'b0;
					if(sb_ready_m2 && sb_grant_m2) begin
						wr_state <=STATE_WR_CONTRL; 
					end
					else begin
						wr_state <=STATE_SPLIT_OCCUR;
					end
				end
			endcase
			end
			else begin
				wr_state <= STATE_INIT_BUS_REQ;
			end
		end
	end
	
	always @(posedge sb_clk)begin
		if(!sb_resetn)begin
			rd_en <=1'b1;
			current_read_burst <= {SB_TRANS_SIZE*{1'b0}};
			num_burst <= {SB_TRANS_SIZE*{1'b0}};
			rd_state<=STATE_INIT_BUS_RD_REQ;
		end
		else begin
			rd_en <= usr_contl_cmd_m2;
			if(!rd_en && usr_valid_m2) begin
			case(rd_state) 
				STATE_INIT_BUS_RD_REQ : begin
					sb_busreq_m2 <= 1'b1;
					if(sb_grant_m2)begin
					rd_state  <= STATE_RD_CONTRL;
					sb_addr_m2	<= usr_add_m2;
					end
					else begin
						rd_state  <= STATE_INIT_BUS_RD_REQ;
					end
				end
				STATE_RD_CONTRL	: begin
					if(sb_ready_m2)begin
						sb_addr_m2	<= usr_add_m2;
						sb_write_m2	<= 1'b0;
						sb_size_m2	<= usr_size_m2;
						sb_burst_m2	<= INCR;
						rd_state  <= STATE_RD_DATA;
						num_burst<= usr_num_burst_m2;
			        end
				end
				STATE_RD_DATA	: begin
					if(sb_resp_m2==OKAY && current_read_burst<num_burst)begin
						rd_data <= sb_rdata_m2;
						current_read_burst<=current_read_burst+1;
					end
					else if(sb_resp_m2==SPLIT) begin
						rd_state  <= STATE_SPLIT_RDOCCUR;
					end
					else if(sb_resp_m2==OKAY && current_read_burst==num_burst) begin
						rd_state  <= STATE_RD_FINISH;
					end
					else begin
						rd_state  <= STATE_INIT_BUS_RD_REQ;
						current_read_burst <= {SB_TRANS_SIZE*{1'b0}};
						num_burst <= {SB_TRANS_SIZE*{1'b0}};
					end
				end
				STATE_RD_FINISH	: begin
					rd_state  <= STATE_INIT_BUS_RD_REQ;
					current_read_burst <= {SB_TRANS_SIZE*{1'b0}};
					num_burst <= {SB_TRANS_SIZE*{1'b0}};
					sb_busreq_m2 <= 1'b0;
				end
				STATE_SPLIT_RDOCCUR : begin
					sb_trans_m2 <= IDLE;
					if(sb_ready_m2 && sb_grant_m2) begin
						rd_state <=STATE_RD_DATA; 
					end
					else begin
						rd_state <=STATE_SPLIT_RDOCCUR;
					end
				end
			endcase
				
			end
			else begin
				rd_state<=STATE_INIT_BUS_RD_REQ;
			end
	    end
	end
endmodule
