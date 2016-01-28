//***************************************************************************//
//
// SUPARCO/SRDC-K/IPS
//
// Project                    : AES Encryptor Core
// Module                     : aes_keyscheduler
// Designer                   : AAK
// Date of creation           : 20 July, 2007
// Date of last modifaction   : 21 July, 2007
//
// Description                : Key Scheduler
//
//
// Revision                   :
//
// Revision History
//
// Date       Version       Designer      Change         Description
//
//
//***************************************************************************//

`include "./byte_def.v"

module key128_exp
(
  input mclk                      ,		// Master clock
  input arst_n                    ,		// active low asynchronous reset

// inputs
  input [0:127] ck128_master			,		// 128 bits Cipher Key input
  input         start128         ,		// load enable signal for the cipher key

// outputs
  output reg [0:127] rk128   			,		// 128 bits Round Key output
  output reg [3:0]   rk128_count	,
  output reg      	 rk128_le			,
  output reg         busy128
);


// Interconnections
reg  [0:127] sk128_prev;      // Previous set Key
wire [0:127] sk128_curr;      // Transformed current set key
reg  [3:0]   sk128_count;
reg          sbox_en;


// =======================
// ASMD implementation
// =======================

//// state machine
reg [2:0] state, nextState;
parameter IDLE = 3'b001 ,
          LOAD = 3'b010 ,
          LODN = 3'b100 ;

always @(posedge mclk or negedge arst_n)
begin
  if (! arst_n)
    state <= IDLE;	
  else
    state <= nextState;
end
	
always @*
begin
  case (state)
    IDLE:	
      if (start128) 
        nextState = LOAD ;
      else
        nextState = IDLE ;
    LOAD:	
      if (rk128_count != 4'd10)
				nextState = LODN ;
      else
        nextState = IDLE ;
    LODN:	
        nextState = LOAD ;
    default:
      nextState = IDLE ;
  endcase
end

//// register transfers
always @(posedge mclk or negedge arst_n)
begin
  if (! arst_n)
  begin
    sk128_prev <= 0 ;
    rk128_count <= 0 ;
  end
  else
  begin
    case (state)
      IDLE:
				if (start128)
				begin
					sk128_prev <= ck128_master ;
					rk128_count <= 4'd0 ;
				end

      LODN:
      begin
        sk128_prev <= sk128_curr ;
				rk128_count <= rk128_count + 1'b1 ;
      end
			
    endcase
  end
end

//// Combinational outputs
always @*
begin
  sbox_en = 0 ;
  rk128_le = 0 ;
  busy128 = 0 ;
  rk128 = sk128_prev ;
  sk128_count = rk128_count + 1'b1 ;

  case (state)
		IDLE:
			if (start128)
				busy128 = 1 ;
		LOAD:
		begin
			sbox_en = 1 ;
			rk128_le = 1 ;
			busy128 = 1 ;
		end
		LODN:
			busy128 = 1 ;
  endcase
end


// =================================
// Key Expansion Transformations
// =================================

wire [0:31] subbytes_col;
wire [0:31] rotword_col;
wire [0:31] rcon_xor_col;

// Round Constant Word Array
wire [0:7] rcon_byte [1:10] ;
assign rcon_byte[1] = 8'h01 ;
assign rcon_byte[2] = 8'h02 ;
assign rcon_byte[3] = 8'h04 ;
assign rcon_byte[4] = 8'h08 ;
assign rcon_byte[5] = 8'h10 ;
assign rcon_byte[6] = 8'h20 ;
assign rcon_byte[7] = 8'h40 ;
assign rcon_byte[8] = 8'h80 ;
assign rcon_byte[9] = 8'h1B ;
assign rcon_byte[10]= 8'h36 ;

// Sub Bytes Transformation
sbox sbox0 (mclk, sbox_en, sk128_prev[`BYTE03], subbytes_col[`BYTE0]) ;
sbox sbox1 (mclk, sbox_en, sk128_prev[`BYTE13], subbytes_col[`BYTE1]) ;
sbox sbox2 (mclk, sbox_en, sk128_prev[`BYTE23], subbytes_col[`BYTE2]) ;
sbox sbox3 (mclk, sbox_en, sk128_prev[`BYTE33], subbytes_col[`BYTE3]) ;
                        
// Rotate Word Transformation
assign rotword_col[`BYTE0] = subbytes_col[`BYTE1] ;
assign rotword_col[`BYTE1] = subbytes_col[`BYTE2] ;
assign rotword_col[`BYTE2] = subbytes_col[`BYTE3] ;
assign rotword_col[`BYTE3] = subbytes_col[`BYTE0] ;
                          
// XOR with Rcon byte
assign rcon_xor_col[`BYTE0] = rotword_col[`BYTE0] ^ rcon_byte[sk128_count] ;
assign rcon_xor_col[`BYTE1] = rotword_col[`BYTE1] ;
assign rcon_xor_col[`BYTE2] = rotword_col[`BYTE2] ;
assign rcon_xor_col[`BYTE3] = rotword_col[`BYTE3] ;
                           
// Generate current set Key with XOR
assign sk128_curr[`COL0] = sk128_prev[`COL0] ^ rcon_xor_col ;
assign sk128_curr[`COL1] = sk128_prev[`COL1] ^ sk128_curr[`COL0] ;
assign sk128_curr[`COL2] = sk128_prev[`COL2] ^ sk128_curr[`COL1] ;
assign sk128_curr[`COL3] = sk128_prev[`COL3] ^ sk128_curr[`COL2] ;



endmodule
