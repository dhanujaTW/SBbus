`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2017 14:01:56
// Design Name: 
// Module Name: n
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


module SBtop(
   sb_clk,
   sb_resetn,
   
   usr_contl_cmd_m1,
   usr_size_m1,	
   usr_data_m1,	
   usr_num_burst_m1,
   usr_add_m1,
   usr_valid_m1,
   
   usr_send_rdy_m1,
  // usr_stop,
   
   usr_contl_cmd_m2,
   usr_valid_m2,
   usr_size_m2,	
   usr_data_m2,	
   usr_num_burst_m2,
   usr_add_m2,
   usr_send_rdy_m2
      
   
    );
	
//---------------------------------------------------------------------------------------------------------------------	
// parameter definitionsendmodule
//---------------------------------------------------------------------------------------------------------------------
    
//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
 
    localparam                          SB_ADDR_WIDTH         = 32;
    localparam                          SB_TRAS_TYPE          = 2;
    localparam   					    SB_TRANS_SIZE         = 3;	
    localparam                          SB_BURST_NUM          = 3;
    localparam                          SB_WDATA_WIDTH        = 32;
	localparam                          SB_RDATA_WIDTH        = 32;
	localparam                          SB_RESP_TYPE          = 2;
	localparam                          SB_SPLIT_NUM_MASTERS  = 2;
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------

    input                                   sb_clk;
    input                                   sb_resetn;	
	
	input                                  usr_contl_cmd_m1;
	input  								   usr_valid_m1;
	input 		[SB_TRANS_SIZE-1:0]		   usr_size_m1;
	input		[SB_WDATA_WIDTH-1:0]	   usr_data_m1;
	input		[SB_TRANS_SIZE-1:0]        usr_num_burst_m1;
	input 		[SB_ADDR_WIDTH-1:0]        usr_add_m1;								   
	output wire							   usr_send_rdy_m1;
	//output wire usr_stop;
	
	input                                  usr_contl_cmd_m2;
	input  								   usr_valid_m2;
	input 		[SB_TRANS_SIZE-1:0]		   usr_size_m2;
	input		[SB_WDATA_WIDTH-1:0]	   usr_data_m2;
	input		[SB_TRANS_SIZE-1:0]        usr_num_burst_m2;
	input [SB_ADDR_WIDTH-1:0]              usr_add_m2;									   
	output wire							   usr_send_rdy_m2;
	
	wire                      				sb_busreq_m1_wire;
	wire                      				sb_lock_m1_wire;
	wire                      				sb_busreq_m2_wire;
	wire                      				sb_lock_m2_wire;
	wire [SB_ADDR_WIDTH-1:0]				sb_addr_ar_wire;
	wire [SB_ADDR_WIDTH-1:0]				sb_addr_m1_wire;
	wire [SB_ADDR_WIDTH-1:0]				sb_addr_m2_wire;
	wire 									sb_grant_m1_wire;
	wire 									sb_grant_m2_wire;
	wire									sb_sel_s1_wire;
	wire									sb_sel_s2_wire;
	wire									sb_sel_s3_wire;
	wire [SB_TRAS_TYPE-1:0]    				sb_trans_ar_wire;
	wire [SB_TRAS_TYPE-1:0]    				sb_trans_m1_wire;
	wire [SB_TRAS_TYPE-1:0]    				sb_trans_m2_wire;
	wire [SB_TRANS_SIZE-1:0]				sb_size_wire;
	wire [SB_TRANS_SIZE-1:0]				sb_size_m1_wire;
	wire [SB_TRANS_SIZE-1:0]				sb_size_m2_wire;
	wire [SB_BURST_NUM-1:0]					sb_burst_ar_wire;
	wire [SB_BURST_NUM-1:0]					sb_burst_m1_wire;
	wire [SB_BURST_NUM-1:0]					sb_burst_m2_wire;
	wire	sb_wtite_wire;		
	wire									sb_write_m1_wire;
	wire									sb_write_m2_wire;
	wire [SB_WDATA_WIDTH-1:0]				sb_wdata_wire;
	wire [SB_WDATA_WIDTH-1:0]				sb_wdata_m1_wire;
	wire [SB_WDATA_WIDTH-1:0]				sb_wdata_m2_wire;
			
	wire [SB_RDATA_WIDTH-1:0] 				rdata_wire;
	wire [SB_RDATA_WIDTH-1:0] 				sb_data_s1_wire;
	wire [SB_RDATA_WIDTH-1:0] 				sb_data_s2_wire;
	wire [SB_RDATA_WIDTH-1:0] 				sb_data_s3_wire;
	wire 									sb_ready_ar_wire;
	wire 									sb_ready_s1_wire;
	wire 									sb_ready_s2_wire;
	wire 									sb_ready_s3_wire;
	wire									add_notokay_wire;
	wire [SB_RESP_TYPE-1:0] 				sb_resp_ar_wire;
	wire [SB_RESP_TYPE-1:0] 				sb_resp_s1_wire;
	wire [SB_RESP_TYPE-1:0] 				sb_resp_s2_wire;
	wire [SB_RESP_TYPE-1:0] 				sb_resp_s3_wire;
	wire [SB_RESP_TYPE-1:0]					sb_resp_wire;
	wire [SB_SPLIT_NUM_MASTERS-1:0] 		sb_split_ar_wire;
	wire [SB_SPLIT_NUM_MASTERS-1:0] 		sb_split_s1_wire;
	wire [SB_SPLIT_NUM_MASTERS-1:0] 		sb_split_s2_wire;
	wire [SB_SPLIT_NUM_MASTERS-1:0] 		sb_split_s3_wire;
			
	wire						    		sb_masters_wire;
	
	
	SBarbiter			arbr_instance(
		
		.sb_clk				(sb_clk),
		.sb_resetn			(sb_resetn),
	
		.sb_busreq_m1		(sb_busreq_m1_wire),
		.sb_lock_m1			(sb_lock_m1_wire),
		.sb_busreq_m2		(sb_busreq_m2_wire),
		.sb_lock_m2			(sb_lock_m2_wire),
			
		.sb_addr_ar			(sb_addr_ar_wire),
		.sb_split_ar		(sb_split_ar_wire),
		.sb_trans_ar		(sb_trans_ar_wire),
		.sb_burst_ar		(sb_burst_ar_wire),
		.sb_resp_ar		    (sb_resp_ar_wire),
		.sb_ready_ar		(sb_ready_ar_wire),
		
		.sb_grant_m1		(sb_grant_m1_wire),
		.sb_grant_m2		(sb_grant_m2_wire),
		.sb_masters			(sb_masters_wire),
		.sb_mastlock     	()
    );

	SBmaster1			mstr1_instance(
		
		.sb_resetn			(sb_resetn),
		.sb_clk				(sb_clk),
		
		.sb_grant_m1		(sb_grant_m1_wire),
		.sb_ready_m1		(sb_ready_ar_wire),
		.sb_resp_m1		    (sb_resp_ar_wire),
		.sb_rdata_m1		(rdata_wire),
		
		.sb_busreq_m1		(sb_busreq_m1_wire),
		.sb_lock_m1			(sb_lock_m1_wire),
		.sb_trans_m1		(sb_trans_m1_wire),
		.sb_addr_m1			(sb_addr_m1_wire),
		.sb_write_m1		(sb_write_m1_wire),	
		.sb_size_m1			(sb_size_m1_wire),
		.sb_burst_m1		(sb_burst_m1_wire),	
		.sb_wdata_m1     	(sb_wdata_m1_wire),
		
		.usr_contl_cmd_m1      (usr_contl_cmd_m1),
		.usr_size_m1		   (usr_size_m1),
		.usr_data_m1		   (usr_data_m1),
		.usr_num_burst_m1	   (usr_num_burst_m1),
        .usr_add_m1				(usr_add_m1),
		.usr_valid_m1			(usr_valid_m1),
		
		.usr_send_rdy_m1       (usr_send_rdy_m1)
		
		);
		
	SBmaster2			mstr2_instance(
		
		.sb_resetn			(sb_resetn),
		.sb_clk				(sb_clk),
		                
		.sb_grant_m2		(sb_grant_m2_wire),
		.sb_ready_m2		(sb_ready_ar_wire),
		.sb_resp_m2		    (sb_resp_ar_wire),
		.sb_rdata_m2		(rdata_wire),
		                
		.sb_busreq_m2		(sb_busreq_m2_wire),
		.sb_lock_m2			(sb_lock_m2_wire),
		.sb_trans_m2		(sb_trans_m2_wire),
		.sb_addr_m2			(sb_addr_m2_wire),
		.sb_write_m2		(sb_write_m2_wire),
		.sb_size_m2			(sb_size_m2_wire),
		.sb_burst_m2		(sb_burst_m2_wire),
		.sb_wdata_m2     	(sb_wdata_m2_wire),
		
		.usr_contl_cmd_m2      (usr_contl_cmd_m2),
		.usr_size_m2		   (usr_size_m2),
		.usr_data_m2		   (usr_data_m2),
		.usr_num_burst_m2	   (usr_num_burst_m2),
        .usr_add_m2 			(usr_add_m2),
		.usr_valid_m2			(usr_valid_m2),
		.usr_send_rdy_m2       (usr_send_rdy_m2)		
	
		);
	
	SBslave1			slv1_instance(
	
		.sb_clk				(sb_clk),
		.sb_resetn			(sb_resetn),
		
		.sb_sel_s1			(sb_sel_s1_wire),
		.sb_addr_s1			(sb_addr_ar_wire),
		.sb_write_s1		(sb_wtite_wire),
		.sb_trans_s1		(sb_trans_ar_wire),
		.sb_size_s1			(sb_size_wire),
		.sb_burst_s1		(sb_burst_ar_wire),
		.sb_wdata_s1		(sb_wdata_wire),
		
		.sb_master_s1	    (sb_masters_wire),	
		.sb_mastlock		(),
		
		.sb_ready_s1		(sb_ready_s1_wire),
		.sb_resp_s1		    (sb_resp_s1_wire),
		.sb_data_s1			(sb_data_s1_wire),
		.sb_split_s1        (sb_split_s1_wire) // this signal gives infor about hold master. 2 masters so width2
	
		);
		
	SBslave2			slv2_instance(
	
		.sb_clk			(	sb_clk),
		.sb_resetn		(	sb_resetn),
		                
		.sb_sel_s2			(sb_sel_s2_wire),
		.sb_addr_s2			(sb_addr_ar_wire),
		.sb_write_s2		(sb_wtite_wire),
		.sb_trans_s2		(sb_trans_ar_wire),
		.sb_size_s2			(sb_size_wire),
		.sb_burst_s2		(sb_burst_ar_wire),
		.sb_wdata_s2		(sb_wdata_wire),
		                
		.sb_master_s2		(sb_masters_wire),
		.sb_mastlock		(),
		                
		.sb_ready_s2		(sb_ready_s2_wire),	
		.sb_resp_s2			(sb_resp_s2_wire),
		.sb_data_s2			(sb_data_s2_wire),
		.sb_split_s2     	(sb_split_s2_wire)
	
		);
	
	SBslave3			slv3_instance(
	
		.sb_clk				(sb_clk),
		.sb_resetn			(sb_resetn),
		                
		.sb_sel_s3			(sb_sel_s3_wire),
		.sb_addr_s3			(sb_addr_ar_wire),
		.sb_write_s3		(sb_wtite_wire),
		.sb_trans_s3		(sb_trans_ar_wire),
		.sb_size_s3			(sb_size_wire),
		.sb_burst_s3		(sb_burst_ar_wire),
		.sb_wdata_s3		(sb_wdata_wire),
		                
		.sb_master_s3		(sb_masters_wire),
		.sb_mastlock		(),
		                
		.sb_ready_s3		(sb_ready_s3_wire),
		.sb_resp_s3			(sb_resp_s3_wire),
		.sb_data_s3			(sb_data_s3_wire),
		.sb_split_s3     	(sb_split_s3_wire)
	
		);
		
	SBdecoder			dcdr_instance(

		.sb_clk				(sb_clk),
		.sb_resetn			(sb_resetn),	
		.sb_size            (sb_size_wire),
		.sb_addr			(sb_addr_ar_wire),
		.sb_sel_s1			(sb_sel_s1_wire),
		.sb_sel_s2			(sb_sel_s2_wire),
		.sb_sel_s3			(sb_sel_s3_wire),
		
		.add_notokay        (add_notokay_wire),
		.sb_resp			(sb_resp_wire)
	
		);
	
 assign sb_addr_ar_wire	 = (sb_masters_wire)? sb_addr_m1_wire:sb_addr_m2_wire;
 assign sb_trans_ar_wire = (sb_masters_wire)? sb_trans_m1_wire:sb_trans_m2_wire;
 assign sb_burst_ar_wire = (sb_masters_wire)? sb_burst_m1_wire:sb_burst_m2_wire;
 assign sb_size_wire	 = (sb_masters_wire)? sb_size_m1_wire:sb_size_m2_wire;
 assign sb_wtite_wire 	 = (sb_masters_wire)? sb_write_m1_wire:sb_write_m2_wire;
 assign sb_wdata_wire 	 = (sb_masters_wire)? sb_wdata_m1_wire:sb_wdata_m2_wire;
 

  assign rdata_wire			= (sb_sel_s1_wire)?sb_data_s1_wire:(sb_sel_s2_wire) ?sb_data_s2_wire:sb_data_s3_wire;
  assign sb_ready_ar_wire 	= (sb_sel_s1_wire)?sb_ready_s1_wire:(sb_sel_s2_wire) ?sb_ready_s2_wire: sb_ready_s3_wire;
  assign sb_resp_ar_wire  	= (add_notokay_wire)?sb_resp_wire:(sb_sel_s1_wire && !add_notokay_wire)?sb_resp_s1_wire:(sb_sel_s2_wire && !add_notokay_wire) ? sb_resp_s2_wire: sb_resp_s3_wire;
  assign sb_split_ar_wire 	= (sb_sel_s1_wire)?sb_split_s1_wire:(sb_sel_s2_wire) ?sb_split_s2_wire:sb_split_s3_wire;
 

 
  
endmodule
