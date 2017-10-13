`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2017 14:06:18
// Design Name: 
// Module Name: SBarbiter
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


module SBarbiter(
 sb_clk,
 sb_resetn,
 
 sb_busreq_m1,
 sb_lock_m1,
 sb_busreq_m2,
 sb_lock_m2,
 
 sb_addr_ar,
 sb_split_ar,
 sb_trans_ar,
 sb_burst_ar,
 sb_resp_ar,
 sb_ready_ar,
 
 sb_grant_m1,
 sb_grant_m2,
 sb_masters,
 sb_mastlock
    );
//---------------------------------------------------------------------------------------------------------------------	
// parameter definitionsendmodule
//---------------------------------------------------------------------------------------------------------------------
    
//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
 
    localparam                          SB_ADDR_WIDTH         = 32;                             
    localparam                          SB_TRAS_TYPE          = 2;
    localparam                          SB_BURST_NUM          = 3;
	localparam                          SB_RESP_TYPE          = 2;
	localparam                          SB_NUM_MASTER         = 1;
	localparam                          SB_SPLIT_NUM_MSTR     = 2;
	

//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    input                                   sb_clk;
	input									sb_resetn;
    input                                   sb_busreq_m1;
    input                                   sb_lock_m1;
    input                                   sb_busreq_m2;
    input                                   sb_lock_m2;
                                            
    input		[SB_ADDR_WIDTH-1:0]	 		sb_addr_ar;
    input       [SB_SPLIT_NUM_MSTR-1:0]     sb_split_ar;
    input       [SB_TRAS_TYPE-1:0]          sb_trans_ar;
    input       [SB_BURST_NUM-1:0]          sb_burst_ar;
	input       [SB_RESP_TYPE-1:0]          sb_resp_ar;
    input                                   sb_ready_ar;
	
	output reg     	                        sb_grant_m1;
    output reg      	   				    sb_grant_m2;
	output reg  [SB_NUM_MASTER-1:0]         sb_masters;
	output reg                              sb_mastlock;            
	 
	 
	  
	
	always @(posedge sb_clk)begin
		if(!sb_resetn)begin
		end
		else begin
			if(sb_busreq_m1)begin
				if(sb_split_ar==2'b01)begin
					sb_grant_m2<=1'b1;
					sb_grant_m1<=1'b0;
					sb_masters<=1'b0;
				end
				else begin
					sb_grant_m1<=1'b1;
					sb_grant_m2<=1'b0;
					sb_masters<=1'b1;
				end
				
			end
			else if (sb_busreq_m2)begin
				if(sb_split_ar==2'b10)begin
					sb_grant_m1<=1'b1;
					sb_grant_m2<=1'b0;
					sb_masters<=1'b1;
				end
				else begin
					sb_grant_m2<=1'b1;
					sb_grant_m1<=1'b0;
					sb_masters<=1'b0;
				end
			end
			else begin
				sb_grant_m1<=1'b0;
				sb_grant_m2<=1'b0;
			end
		end
	end
endmodule 