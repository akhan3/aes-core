//***************************************************************************//
//
// <name of company working for>
//
// Project                    : AES Encryptor Core
// Module                     : Round Transformations
// Designer                   : AAK
// Date of creation           : 16 July, 2007
// Date of last modifaction   : 16 July, 2007
//
// Description                : 
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

module encryptor
(
  input mclk                        ,           // Master clock
  input arst_n                      ,           // active low asynchronous reset

// inputs	
  input [0:127] plaintext           ,           // 128 bits Plain Text input
  input [0:127] roundkey            ,           // 128 bits Round Key input
	input 				start_enc						,						//
	input 				keylength128		,
	input					keylength192		,
	input 				keylength256		,

// outputs
  output     [0:127] ciphertext     ,           // 128 bits Cipher Text output
  output reg 				 ciphertext_dv  ,           // 
	output reg   [3:0] round_count		,						//
  output reg 				 busy_enc                   // 
);

// Interconnections
reg  [0:127] roundstate_prev;		// Previous set Key
wire [0:127] roundstate_curr;   // Transformed current set key
reg          sbox_en;

assign ciphertext = roundstate_prev ;


// =======================
// ASMD implementation
// =======================

reg [3:0] round_num;
always @*
begin
	round_num = 4'd10 ;
	if (keylength128)
		round_num = 4'd10 ;
	else if (keylength192)
		round_num = 4'd12 ;
	else if (keylength256)
		round_num = 4'd14 ;
end

//// state machine
reg [2:0] state, nextState;
parameter IDLE = 3'b001 ,
          SBOX = 3'b010 ,
          EXOR = 3'b100 ;

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
      if (start_enc) 
        nextState = SBOX ;
      else
        nextState = IDLE ;
    SBOX:	
      nextState = EXOR ;
    EXOR:	
      if (round_count != round_num)
				nextState = SBOX ;
      else
        nextState = IDLE ;
    default:
      nextState = IDLE ;
  endcase
end

//// register transfers
always @(posedge mclk or negedge arst_n)
begin
  if (! arst_n)
  begin
    roundstate_prev <= 0 ;
    round_count <= 0 ;
		ciphertext_dv <= 0 ;
  end
  else
  begin
    case (state)
      IDLE:
			begin
				ciphertext_dv <= 0 ;
        if (start_enc)
        begin
          roundstate_prev <= roundstate_curr ;
          round_count <= 4'd1 ;
        end
			end
      EXOR:
			begin
        roundstate_prev <= roundstate_curr ;
				if (round_count != round_num)
					round_count <= round_count + 1'b1 ;
				else
				begin
					round_count <= 0 ;
					ciphertext_dv <= 1 ;
				end
      end
    endcase
  end
end

//// Combinational outputs
always @*
begin
  sbox_en = 0 ;
  busy_enc = 0 ;
  case (state)
		IDLE:
			if (start_enc)
				busy_enc = 1 ;
		SBOX:
		begin
			busy_enc = 1 ;
			sbox_en = 1 ;
		end
		EXOR:
			busy_enc = 1 ;
  endcase
end


// =================================
// Round Transformations
// =================================
reg  [0:127] mux_out;
wire [0:127] subbytes;
wire [0:127] shiftrows;
wire [0:127] mixcolumns;

// Round MUX
always @*
begin
	if (round_count == 4'd0)
		mux_out = plaintext ;
	else if (round_count != round_num)
		mux_out = mixcolumns ;
	else
		mux_out = shiftrows ;
end


// roundstate_curr using XOR
assign roundstate_curr = mux_out ^ roundkey ;


// Sub Bytes Transformation is applied byte by byte
sbox sbox00 (mclk, sbox_en, roundstate_prev[`BYTE00], subbytes[`BYTE00]) ;
sbox sbox01 (mclk, sbox_en, roundstate_prev[`BYTE01], subbytes[`BYTE01]) ;
sbox sbox02 (mclk, sbox_en, roundstate_prev[`BYTE02], subbytes[`BYTE02]) ;
sbox sbox03 (mclk, sbox_en, roundstate_prev[`BYTE03], subbytes[`BYTE03]) ;

sbox sbox10 (mclk, sbox_en, roundstate_prev[`BYTE10], subbytes[`BYTE10]) ;
sbox sbox11 (mclk, sbox_en, roundstate_prev[`BYTE11], subbytes[`BYTE11]) ;
sbox sbox12 (mclk, sbox_en, roundstate_prev[`BYTE12], subbytes[`BYTE12]) ;
sbox sbox13 (mclk, sbox_en, roundstate_prev[`BYTE13], subbytes[`BYTE13]) ;

sbox sbox20 (mclk, sbox_en, roundstate_prev[`BYTE20], subbytes[`BYTE20]) ;
sbox sbox21 (mclk, sbox_en, roundstate_prev[`BYTE21], subbytes[`BYTE21]) ;
sbox sbox22 (mclk, sbox_en, roundstate_prev[`BYTE22], subbytes[`BYTE22]) ;
sbox sbox23 (mclk, sbox_en, roundstate_prev[`BYTE23], subbytes[`BYTE23]) ;

sbox sbox30 (mclk, sbox_en, roundstate_prev[`BYTE30], subbytes[`BYTE30]) ;
sbox sbox31 (mclk, sbox_en, roundstate_prev[`BYTE31], subbytes[`BYTE31]) ;
sbox sbox32 (mclk, sbox_en, roundstate_prev[`BYTE32], subbytes[`BYTE32]) ;
sbox sbox33 (mclk, sbox_en, roundstate_prev[`BYTE33], subbytes[`BYTE33]) ;


// Shift Rows Transformation is applied row by row
assign shiftrows[`BYTE00] = subbytes[`BYTE00] ;
assign shiftrows[`BYTE01] = subbytes[`BYTE01] ;
assign shiftrows[`BYTE02] = subbytes[`BYTE02] ;
assign shiftrows[`BYTE03] = subbytes[`BYTE03] ;
  
assign shiftrows[`BYTE10] = subbytes[`BYTE11] ;
assign shiftrows[`BYTE11] = subbytes[`BYTE12] ;
assign shiftrows[`BYTE12] = subbytes[`BYTE13] ;
assign shiftrows[`BYTE13] = subbytes[`BYTE10] ;
  
assign shiftrows[`BYTE20] = subbytes[`BYTE22] ;
assign shiftrows[`BYTE21] = subbytes[`BYTE23] ;
assign shiftrows[`BYTE22] = subbytes[`BYTE20] ;
assign shiftrows[`BYTE23] = subbytes[`BYTE21] ;
  
assign shiftrows[`BYTE30] = subbytes[`BYTE33] ;
assign shiftrows[`BYTE31] = subbytes[`BYTE30] ;
assign shiftrows[`BYTE32] = subbytes[`BYTE31] ;
assign shiftrows[`BYTE33] = subbytes[`BYTE32] ;


// Mix Columns Transformation is applied column by column
assign mixcolumns[`BYTE00] = xtime(shiftrows[`BYTE00] ^ shiftrows[`BYTE10]) ^ (shiftrows[`BYTE20] ^ shiftrows[`BYTE30]) ^ shiftrows[`BYTE10] ;
assign mixcolumns[`BYTE10] = xtime(shiftrows[`BYTE10] ^ shiftrows[`BYTE20]) ^ (shiftrows[`BYTE30] ^ shiftrows[`BYTE00]) ^ shiftrows[`BYTE20] ;
assign mixcolumns[`BYTE20] = xtime(shiftrows[`BYTE20] ^ shiftrows[`BYTE30]) ^ (shiftrows[`BYTE00] ^ shiftrows[`BYTE10]) ^ shiftrows[`BYTE30] ;
assign mixcolumns[`BYTE30] = xtime(shiftrows[`BYTE30] ^ shiftrows[`BYTE00]) ^ (shiftrows[`BYTE10] ^ shiftrows[`BYTE20]) ^ shiftrows[`BYTE00] ;

assign mixcolumns[`BYTE01] = xtime(shiftrows[`BYTE01] ^ shiftrows[`BYTE11]) ^ (shiftrows[`BYTE21] ^ shiftrows[`BYTE31]) ^ shiftrows[`BYTE11] ;
assign mixcolumns[`BYTE11] = xtime(shiftrows[`BYTE11] ^ shiftrows[`BYTE21]) ^ (shiftrows[`BYTE31] ^ shiftrows[`BYTE01]) ^ shiftrows[`BYTE21] ;
assign mixcolumns[`BYTE21] = xtime(shiftrows[`BYTE21] ^ shiftrows[`BYTE31]) ^ (shiftrows[`BYTE01] ^ shiftrows[`BYTE11]) ^ shiftrows[`BYTE31] ;
assign mixcolumns[`BYTE31] = xtime(shiftrows[`BYTE31] ^ shiftrows[`BYTE01]) ^ (shiftrows[`BYTE11] ^ shiftrows[`BYTE21]) ^ shiftrows[`BYTE01] ;

assign mixcolumns[`BYTE02] = xtime(shiftrows[`BYTE02] ^ shiftrows[`BYTE12]) ^ (shiftrows[`BYTE22] ^ shiftrows[`BYTE32]) ^ shiftrows[`BYTE12] ;
assign mixcolumns[`BYTE12] = xtime(shiftrows[`BYTE12] ^ shiftrows[`BYTE22]) ^ (shiftrows[`BYTE32] ^ shiftrows[`BYTE02]) ^ shiftrows[`BYTE22] ;
assign mixcolumns[`BYTE22] = xtime(shiftrows[`BYTE22] ^ shiftrows[`BYTE32]) ^ (shiftrows[`BYTE02] ^ shiftrows[`BYTE12]) ^ shiftrows[`BYTE32] ;
assign mixcolumns[`BYTE32] = xtime(shiftrows[`BYTE32] ^ shiftrows[`BYTE02]) ^ (shiftrows[`BYTE12] ^ shiftrows[`BYTE22]) ^ shiftrows[`BYTE02] ;

assign mixcolumns[`BYTE03] = xtime(shiftrows[`BYTE03] ^ shiftrows[`BYTE13]) ^ (shiftrows[`BYTE23] ^ shiftrows[`BYTE33]) ^ shiftrows[`BYTE13] ;
assign mixcolumns[`BYTE13] = xtime(shiftrows[`BYTE13] ^ shiftrows[`BYTE23]) ^ (shiftrows[`BYTE33] ^ shiftrows[`BYTE03]) ^ shiftrows[`BYTE23] ;
assign mixcolumns[`BYTE23] = xtime(shiftrows[`BYTE23] ^ shiftrows[`BYTE33]) ^ (shiftrows[`BYTE03] ^ shiftrows[`BYTE13]) ^ shiftrows[`BYTE33] ;
assign mixcolumns[`BYTE33] = xtime(shiftrows[`BYTE33] ^ shiftrows[`BYTE03]) ^ (shiftrows[`BYTE13] ^ shiftrows[`BYTE23]) ^ shiftrows[`BYTE03] ;


// xtime() function to modular multiply a byte by 2
function [7:0] xtime (input [7:0] x_in);
  xtime = x_in[7] ? (x_in<<1) ^ 8'b0001_1011 : (x_in<<1) ;
endfunction 

endmodule
