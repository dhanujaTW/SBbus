`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2017 14:06:56
// Design Name: 
// Module Name: SBdecoder
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


module SBdecoder(
 sb_clk,
 sb_resetn,
 
 sb_addr,
 sb_size,
 sb_sel_s1,
 sb_sel_s2,
 sb_sel_s3,
 
 add_notokay,
 sb_resp

    );
	
//---------------------------------------------------------------------------------------------------------------------	
// parameter definitionsendmodule
//---------------------------------------------------------------------------------------------------------------------
    
//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
 
    localparam                          SB_ADDR_WIDTH         = 32; 
	localparam							HIGH_BIT			  = 30;
	localparam							BIT_WIDTH   		  = 2;
	localparam							ADD1_WIDTH  		  = 30;
	localparam							ADD2_WIDTH  		  = 30;
	localparam                          SB_RESP_TYPE          = 2;
    localparam   					    SB_TRANS_SIZE         = 3;
	localparam               			RESP_STATE_WIDTH 	  = 2;
	localparam [RESP_STATE_WIDTH-1:0] 	ERROR  = 2;
   
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------

                                            
    input [SB_ADDR_WIDTH-1:0]	 					sb_addr;
    input                                   		sb_clk;
    input                                   		sb_resetn;
	input [SB_TRANS_SIZE-1:0]               		sb_size;
		
			
	output reg     	                        		sb_sel_s1;
    output reg      	   				    		sb_sel_s2;
	output reg  					        		sb_sel_s3;  
	output reg										add_notokay;
	output reg [SB_RESP_TYPE-1:0]           		sb_resp;
	
	reg 		[ADD1_WIDTH-1:0]					num_beat;
	reg 		[ADD2_WIDTH-1:0]					num_beat2;
	
	always @(posedge sb_clk)begin
		if(!sb_resetn) begin
			sb_sel_s1			<= 1'b0;
		    sb_sel_s2			<= 1'b0;
		    sb_sel_s3			<= 1'b0;  
		    add_notokay			<= 1'b0;
		    sb_resp				<= {SB_RESP_TYPE*{1'b0}};
		    num_beat			<= {ADD1_WIDTH*{1'b0}};
		    num_beat2			<= {ADD2_WIDTH*{1'b0}};
		
		
		
		
		end
		else begin
		    case(sb_size) 
				3'b010 : num_beat <= 30'd0;
				3'b011 : num_beat <= 30'd1;
				3'b100 : num_beat <= 30'd3;
				3'b101 : num_beat <= 30'd7;
				3'b110 : num_beat <= 30'd15;
				3'b111 : num_beat <= 30'd31;
			endcase
			if(sb_addr[HIGH_BIT+:BIT_WIDTH]==2'b01)begin
			   if(sb_addr[0+:ADD1_WIDTH]+num_beat > 30'd2047)begin
			     sb_resp <= ERROR;
				 add_notokay <= 1'b1;
				 sb_sel_s1 <= 1'b0;
			   end
			   else begin
				add_notokay <= 1'b0;
				sb_sel_s1 <= 1'b1;
			   end
			end
			else if(sb_addr[HIGH_BIT+:BIT_WIDTH]==2'b10)begin
			   if(sb_addr[0+:ADD1_WIDTH]+num_beat>30'd2047)begin
			     sb_resp <= ERROR;
				 add_notokay <= 1'b1;
				 sb_sel_s2 <= 1'b0;
			   end
			   else begin
				add_notokay <= 1'b0;
				sb_sel_s2 <= 1'b1;
				
			   end
			end
			else if(sb_addr[HIGH_BIT+:BIT_WIDTH]==2'b11) begin
			   if(sb_addr[0+:ADD2_WIDTH]+num_beat2>30'd4095)begin
			     sb_resp <= ERROR;
				 add_notokay <= 1'b1;
				 sb_sel_s3 <= 1'b0;
			   end
			   else begin
				add_notokay <= 1'b0;
				sb_sel_s3 <= 1'b1;
				
			   end
			end
			else begin
				sb_sel_s1 <= 1'b0;
				sb_sel_s2 <= 1'b0;
				sb_sel_s3 <= 1'b0;
			end
		
		end
	
	end
	
	

endmodule
