`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2017 14:03:14
// Design Name: 
// Module Name: SBslave1
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


module SBslave3(

 sb_clk,
 sb_resetn,

 sb_sel_s3,
 sb_addr_s3,
 sb_write_s3,
 sb_trans_s3,
 sb_size_s3,
 sb_burst_s3,
 sb_wdata_s3,
 
 sb_master_s3,
 sb_mastlock,
 
 sb_ready_s3,
 sb_resp_s3,
 sb_data_s3,
 sb_split_s3 

    );

//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    
//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
 
    localparam                          SB_ADDR_WIDTH         				= 32;                             
    localparam                          SB_TRAS_TYPE          				= 2;
    localparam   					    SB_TRANS_SIZE         				= 3;
    localparam                          SB_BURST_NUM          				= 3;
    localparam                          SB_WDATA_WIDTH        				= 32;
    localparam                          SB_NUM_MASTER         				= 1;
	localparam                          SB_RESP_TYPE          				= 2;
	localparam                          SB_RDATA_WIDTH        				= 32;
	localparam                          SB_SPLIT_NUM_MASTERS  				= 2;
	
	localparam               			BRAM_ADDR_WIDTH 					= 12;
	localparam               			RESP_STATE_WIDTH 					= 2;
	
    localparam [RESP_STATE_WIDTH-1:0] 	IDLE   								= 0;
	localparam [RESP_STATE_WIDTH-1:0] 	BUSY   								= 1;
	localparam [RESP_STATE_WIDTH-1:0] 	NONSEQ 								= 2;
	localparam [RESP_STATE_WIDTH-1:0] 	SEQ    								= 3;
									
	localparam [RESP_STATE_WIDTH-1:0] 	SPLIT  								= 3;
	localparam [RESP_STATE_WIDTH-1:0] 	OKAY   								= 1;
	localparam [RESP_STATE_WIDTH-1:0] 	ERROR  								= 2;
						
	localparam STATE_WIDTH      											= 5;
	localparam COUNTER_WIDTH      											= 5;
	localparam BRAM_ADDRESS_WIDTH      										= 12;
	
	
    localparam [STATE_WIDTH-1:0]			STATE_EAT_CLK1					= 0;
    localparam [STATE_WIDTH-1:0]			STATE_EAT_CLK2					= 1;	
	localparam [STATE_WIDTH-1:0]			STATE_INIT_SLAVE				= 2;
	localparam [STATE_WIDTH-1:0]			STATE_SLAVE_WRITE				= 3;   
	localparam [STATE_WIDTH-1:0]			STATE_SLAVE_READ				= 4;
	localparam [STATE_WIDTH-1:0]			STATE_SLAVE_WRITE_ADDRESS_ERROR	= 5;
	localparam [STATE_WIDTH-1:0]			STATE_MULTIWRITE_SLAVE			= 6;
	localparam [STATE_WIDTH-1:0]			STATE_RETRANER_M1_SLAVE			= 7;
	localparam [STATE_WIDTH-1:0]			STATE_RETRANER_M2_SLAVE			= 8;
	localparam [STATE_WIDTH-1:0]			STATE_ONECLK_DELAY				= 9;
	localparam [STATE_WIDTH-1:0]			STATE_SLAVE_READ_ADDRESS_ERROR	= 10;
	localparam [STATE_WIDTH-1:0]			STATE_MULTIREAD_SLAVE			= 11;
	localparam [STATE_WIDTH-1:0]			STATE_RETRANER_M1_READ_SLAVE	= 12;
	localparam [STATE_WIDTH-1:0]			STATE_RETRANER_M2_READ_SLAVE	= 13;
	localparam [STATE_WIDTH-1:0]			STATE_EAT_CLK3					= 14;
	localparam [STATE_WIDTH-1:0]			STATE_EAT_CLK4					= 15;
	localparam [STATE_WIDTH-1:0]			STATE_EAT_CLK5					= 16;
	localparam [STATE_WIDTH-1:0]			STATE_EAT_CLK6					= 17;
	localparam [STATE_WIDTH-1:0]			STATE_EAT_CLK7					= 18;
	localparam [STATE_WIDTH-1:0]			STATE_EAT_CLK8					= 19;

//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------

    input                                   sb_clk;
    input                                   sb_resetn;


    // axi4 stream rx interface (connection to donwstream module)
    input							       sb_sel_s3;
    input       [SB_ADDR_WIDTH-1:0]        sb_addr_s3;
    input                                  sb_write_s3;
    input       [SB_TRAS_TYPE-1:0]         sb_trans_s3;
    input       [SB_TRANS_SIZE-1:0]        sb_size_s3;
    input       [SB_BURST_NUM-1:0]         sb_burst_s3;
    input       [SB_WDATA_WIDTH-1:0]       sb_wdata_s3;
	input       [SB_NUM_MASTER-1:0]        sb_master_s3;
	input                                  sb_mastlock;
	
	output reg                             sb_ready_s3;                  
	output reg  [SB_RESP_TYPE-1:0]         sb_resp_s3;
	output wire  [SB_RDATA_WIDTH-1:0]       sb_data_s3;
	output reg  [SB_SPLIT_NUM_MASTERS-1:0] sb_split_s3; 
	
	
	reg [COUNTER_WIDTH-1:0]    		 	num_beat;
	reg [BRAM_ADDRESS_WIDTH-1:0]     	badder;
	reg [SB_ADDR_WIDTH-1:0]    			bwdata;
	reg      						 	bwrite_en;
	reg [COUNTER_WIDTH-1:0]     		current_num_beat;
	reg      							m1_hold;
	reg      							m2_hold;
	reg [COUNTER_WIDTH-1:0]     		premaster1_beat_count;
	reg [COUNTER_WIDTH-1:0]     		premaster1_currentbeat_count;
	reg [BRAM_ADDRESS_WIDTH-1:0]     	premaster1_holdaddress;
	reg [COUNTER_WIDTH-1:0]     		premaster2_beat_count;
	reg [COUNTER_WIDTH-1:0]     		premaster2_currentbeat_count;
	reg [BRAM_ADDRESS_WIDTH-1:0]     	premaster2_holdaddress;
	
	reg [STATE_WIDTH-1:0] slave_state;
	
	
	
	
	always @(posedge sb_clk)begin
		if(!sb_resetn)begin
	 
			slave_state						    <= STATE_EAT_CLK1;
			num_beat        					<= {COUNTER_WIDTH*{1'b0}};
			badder  							<= {BRAM_ADDRESS_WIDTH*{1'b0}};
			bwdata								<= {SB_ADDR_WIDTH*{1'b0}};
			bwrite_en							<= 1'b0;
			current_num_beat					<= {COUNTER_WIDTH*{1'b0}};
			m1_hold								<= 1'b0;
			m2_hold								<= 1'b0;
			premaster1_beat_count				<= {COUNTER_WIDTH*{1'b0}};
			premaster1_currentbeat_count		<= {COUNTER_WIDTH*{1'b0}};
			premaster1_holdaddress				<= {BRAM_ADDRESS_WIDTH*{1'b0}};
			premaster2_beat_count				<= {COUNTER_WIDTH*{1'b0}};
			premaster2_currentbeat_count		<= {COUNTER_WIDTH*{1'b0}};
			premaster2_holdaddress				<= {BRAM_ADDRESS_WIDTH*{1'b0}};
			sb_ready_s3							<= 1'b0; 
			sb_resp_s3							<= IDLE;
//			sb_data_s3							<= {SB_RDATA_WIDTH*{1'b0}};
			sb_split_s3							<= {SB_SPLIT_NUM_MASTERS*{1'b0}};	 
			
		end
		else begin
			if(sb_sel_s3) begin
			sb_ready_s3 <=1'b1;
			case(slave_state) 
				STATE_EAT_CLK1	: begin
					slave_state <= STATE_EAT_CLK2;
				end
			    STATE_EAT_CLK2	: begin
					slave_state <= STATE_INIT_SLAVE;
				end
				STATE_EAT_CLK3	: begin
					slave_state <= STATE_EAT_CLK4;
				end
			    STATE_EAT_CLK4	: begin
					slave_state <= STATE_EAT_CLK5;
				end
				STATE_EAT_CLK5	: begin
					slave_state <= STATE_EAT_CLK1;
				end
				STATE_INIT_SLAVE : begin

					if(sb_write_s3)begin
						slave_state <= STATE_SLAVE_WRITE;
						//bwrite_en <= 1'b1;
					end
					else begin
						slave_state <= STATE_SLAVE_READ;
					end
					case(sb_size_s3) 
						3'b010 : num_beat <= 5'd1;
						3'b011 : num_beat <= 5'd2;
						3'b100 : num_beat <= 5'd3;
						3'b101 : num_beat <= 5'd8;
						3'b110 : num_beat <= 5'd16;
						3'b111 : num_beat <= 5'd32;
					endcase
				    badder <= sb_addr_s3[0+:BRAM_ADDR_WIDTH];
				end
				STATE_SLAVE_WRITE	: begin

					    
						bwrite_en <= 1'b1;
						bwdata <= sb_wdata_s3;
						sb_resp_s3 <= OKAY;
						bwrite_en <= 1'b1;
						if(num_beat==5'd1 && !m1_hold && !m2_hold)begin
						   slave_state <= STATE_EAT_CLK1;
						end
						else begin
							slave_state <= STATE_MULTIWRITE_SLAVE;
							//badder <= badder+11'b1;
						end
					    
				
				end
				STATE_SLAVE_WRITE_ADDRESS_ERROR	: begin
					sb_resp_s3 <= ERROR;
					sb_ready_s3<= 1'b0;
					slave_state <= STATE_INIT_SLAVE;
				end
				STATE_MULTIWRITE_SLAVE	: begin
				    if(current_num_beat < 5'd1 && current_num_beat < num_beat-1)begin
					    badder <= badder+11'b1;
						bwrite_en <= 1'b1;
						bwdata <= sb_wdata_s3;
						sb_resp_s3 <= OKAY;
						current_num_beat<=current_num_beat+1;
						slave_state <= STATE_MULTIWRITE_SLAVE;
					end
					else if(current_num_beat >= 5'd1  && current_num_beat<num_beat)begin
					    sb_resp_s3 <= SPLIT;
						if(sb_master_s3==1'b1)begin
							sb_split_s3 <= 2'b01;
							m1_hold <=1'b1;
							premaster1_beat_count <=num_beat;
							premaster1_currentbeat_count <= current_num_beat;
							premaster1_holdaddress <= badder+11'b1;
							current_num_beat<={COUNTER_WIDTH*{1'b0}};
							slave_state <= STATE_EAT_CLK3;
							
						end
						else begin
						    sb_split_s3 <= 2'b10;
							m2_hold <=1'b1;
							premaster2_beat_count <=num_beat;
							premaster2_currentbeat_count <= current_num_beat;
							premaster2_holdaddress <= badder+11'b1;
							slave_state <= STATE_INIT_SLAVE;
						end
					end
					else if(!m1_hold && !m2_hold)begin
					    slave_state <= STATE_INIT_SLAVE;
						bwrite_en <= 1'b0;
					end
					else begin
					    
						if(m1_hold) begin
							badder <= premaster1_holdaddress;
							slave_state <= STATE_EAT_CLK6;
							sb_split_s3 <= 2'b10;
						end
						else begin
							badder <= premaster2_holdaddress;
							slave_state <= STATE_RETRANER_M2_SLAVE;
							sb_split_s3 <= 2'b01;
						end
						
					end
					
				end
				STATE_EAT_CLK6	: begin
					slave_state <= STATE_EAT_CLK7;
					
				end
				STATE_EAT_CLK7	: begin
					slave_state <= STATE_EAT_CLK8;
					bwdata <= sb_wdata_s3;
				end
				STATE_EAT_CLK8	: begin
					slave_state <= STATE_RETRANER_M1_SLAVE;
				end
				STATE_RETRANER_M1_SLAVE	: begin
					if(m1_hold && premaster1_currentbeat_count <premaster1_beat_count-2)begin
						badder <= badder+12'b1;
						bwrite_en <= 1'b1;
						bwdata <= sb_wdata_s3;
						sb_resp_s3 <= OKAY;
						premaster1_currentbeat_count<=premaster1_currentbeat_count+1;
					end
					else begin
					   m1_hold <=1'b0;
					   slave_state <= STATE_INIT_SLAVE;
					end
				
				end
				STATE_RETRANER_M2_SLAVE	: begin                                                                                
					if(m2_hold && premaster2_currentbeat_count <premaster2_beat_count)begin
						badder <= badder+12'b1;
						bwrite_en <= 1'b1;
						bwdata <= sb_wdata_s3;
						sb_resp_s3 <= OKAY;
						premaster2_currentbeat_count<=premaster2_currentbeat_count+1;
					end
					else begin
					   m2_hold <=1'b0;
					   slave_state <= STATE_INIT_SLAVE;
					end
				
				end
				
				STATE_SLAVE_READ	: begin
				
					  //  badder <= badder;
						bwrite_en <= 1'b0;
						slave_state <= STATE_ONECLK_DELAY;
					    
					
				end
				STATE_ONECLK_DELAY	: begin

					    badder <= badder+12'b1;
						bwrite_en <= 1'b0;
						sb_resp_s3 <= OKAY;
						if(num_beat==5'd1 && !m1_hold && !m2_hold)begin
						   slave_state <= STATE_INIT_SLAVE;
						end
						else begin
							slave_state <= STATE_MULTIREAD_SLAVE;
						end
					    
				end
				
				STATE_SLAVE_READ_ADDRESS_ERROR	: begin
					sb_resp_s3 <= ERROR;
					sb_ready_s3<= 1'b0;
					slave_state <= STATE_INIT_SLAVE;
				end
				STATE_MULTIREAD_SLAVE	: begin
				    if(current_num_beat < 5'd8 && current_num_beat < num_beat)begin
					    badder <= badder+12'b1;
						bwrite_en <= 1'b0;
						sb_resp_s3 <= OKAY;
						current_num_beat<=current_num_beat+1;
					end
					else if(current_num_beat >= 5'd8  && current_num_beat<num_beat)begin
					    sb_resp_s3 <= SPLIT;
						if(sb_master_s3==1'b1)begin
							sb_split_s3 <= 2'b01;
							m1_hold <=1'b1;
							premaster1_beat_count <=num_beat;
							premaster1_currentbeat_count <= current_num_beat;
							premaster1_holdaddress <= badder;
							slave_state <= STATE_INIT_SLAVE;
							
						end
						else begin
						    sb_split_s3 <= 2'b10;
							m2_hold <=1'b1;
							premaster2_beat_count <=num_beat;
							premaster2_currentbeat_count <= current_num_beat;
							premaster2_holdaddress <= badder;
							slave_state <= STATE_INIT_SLAVE;
						end
					end
					else if(!m1_hold && !m2_hold)begin
					    slave_state <= STATE_INIT_SLAVE;
						sb_resp_s3 <= OKAY;
					end
					else begin
					    
						if(m1_hold) begin
							badder <= premaster1_holdaddress;
							slave_state <= STATE_RETRANER_M1_READ_SLAVE;
							sb_split_s3 <= 2'b10;
						end
						else begin
							badder <= premaster2_holdaddress;
							slave_state <= STATE_RETRANER_M2_READ_SLAVE;
							sb_split_s3 <= 2'b01;
						end
						
					end
					
				end
				STATE_RETRANER_M1_READ_SLAVE	: begin
					if(m1_hold && premaster1_currentbeat_count <premaster1_beat_count)begin
						badder <= badder+12'b1;
						bwrite_en <= 1'b0;
						sb_resp_s3 <= OKAY;
						premaster1_currentbeat_count<=premaster1_currentbeat_count+1;
					end
					else begin
					   m1_hold <=1'b0;
					   slave_state <= STATE_INIT_SLAVE;
					end
				
				end
				STATE_RETRANER_M2_READ_SLAVE	: begin
					if(m2_hold && premaster2_currentbeat_count <premaster2_beat_count)begin
						badder <= badder+12'b1;
						bwrite_en <= 1'b1;
						sb_resp_s3 <= OKAY;
						premaster2_currentbeat_count<=premaster2_currentbeat_count+1;
					end
					else begin
					   m2_hold <=1'b0;
					   slave_state <= STATE_INIT_SLAVE;
					end
				
				end
			endcase
				
			end
			else begin
				sb_ready_s3 <=1'b0;
			end
	    end
	end
	
	blk_mem_slave3_4k  block_mem (
		.clka(sb_clk),
		.wea(bwrite_en),
		.addra(badder),
		.dina(bwdata),
		.douta(sb_data_s3)
		);
endmodule
