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

module key192_exp
(
  input mclk                      ,		// Master clock
  input arst_n                    ,		// active low asynchronous reset

// inputs
  input [0:191] ck192_master			,		// 192 bits Cipher Key input
  input         start192             ,		// load enable signal for the cipher key

// outputs
  output reg [0:127] rk192   			,		// 192 bits Round Key output
  output reg [3:0]   rk192_count	,
  output reg      	 rk192_le			,
  output reg         busy192
);


// Interconnections
reg  [0:191] sk192_prev;      // Previous set Key
reg  [0:63]  sk192_buff;
wire [0:191] sk192_curr;      // Transformed current set key
reg  [3:0]   sk192_count;
reg          sbox_en;


// =======================
// ASMD implementation
// =======================

//// state machine
reg [4:0] state, nextState;
parameter IDLE = 5'b00001 ,
          LOD0 = 5'b00010 ,
          LODN = 5'b00100 ,
          LOD1 = 5'b01000 ,
          LOD2 = 5'b10000 ;

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
      if (start192) 
        nextState = LOD0 ;
      else
        nextState = IDLE ;
    LOD0:	
      if (rk192_count != 4'd12)
				nextState = LODN ;
      else
        nextState = IDLE ;
    LODN:	
      nextState = LOD1 ;
    LOD1:	
      nextState = LOD2 ;
    LOD2:	
      nextState = LOD0 ;
    default:
      nextState = IDLE ;
  endcase
end

//// register transfers
always @(posedge mclk or negedge arst_n)
begin
  if (! arst_n)
  begin
    sk192_prev <= 0 ;
		sk192_buff <= 0 ;
    rk192_count <= 0 ;
		sk192_count <= 0 ;
  end
  else
  begin
    case (state)
      IDLE:
				if (start192)
				begin
					sk192_prev <= ck192_master ;
					sk192_buff <= ck192_master[128:191] ;
					rk192_count <= 4'd0 ;
					sk192_count <= 4'd1 ;
				end
				
      LODN:
			begin
				sk192_prev <= sk192_curr ;
				rk192_count <= rk192_count + 1'd1 ;
				sk192_count <= sk192_count + 1'd1 ;
			end
			
      LOD1:
				rk192_count <= rk192_count + 1'd1 ;
				
      LOD2:
			begin
				sk192_prev <= sk192_curr ;
				sk192_buff <= sk192_curr[128:191] ;
				rk192_count <= rk192_count + 1'd1 ;
				sk192_count <= sk192_count + 1'd1 ;
			end
			
    endcase
  end
end

//// Combinational outputs
always @*
begin
	sbox_en = 0 ;
	rk192_le = 0 ;
	busy192 = 0 ;
	rk192 = 128'dX ;

	case (state)
		IDLE:
			if (start192)
				busy192 = 1 ;
				
		LOD0:
		begin
			sbox_en = 1 ;
			rk192_le = 1 ;
			busy192 = 1 ;
			rk192 = sk192_prev[0:127] ;
		end
		LODN:
			busy192 = 1 ;		
		
		LOD1:
		begin
			sbox_en = 1 ;
			rk192_le = 1 ;
			busy192 = 1 ;
			rk192 = {sk192_buff[0:63] , sk192_prev[0:63]} ;
		end
		
		LOD2:
		begin
			rk192_le = 1 ;
			busy192 = 1 ;
			rk192 = sk192_prev[64:191] ;
		end
				
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
sbox sbox0 (mclk, sbox_en, sk192_prev[`BYTE05], subbytes_col[`BYTE0]) ;
sbox sbox1 (mclk, sbox_en, sk192_prev[`BYTE15], subbytes_col[`BYTE1]) ;
sbox sbox2 (mclk, sbox_en, sk192_prev[`BYTE25], subbytes_col[`BYTE2]) ;
sbox sbox3 (mclk, sbox_en, sk192_prev[`BYTE35], subbytes_col[`BYTE3]) ;
                        
// Rotate Word Transformation
assign rotword_col[`BYTE0] = subbytes_col[`BYTE1] ;
assign rotword_col[`BYTE1] = subbytes_col[`BYTE2] ;
assign rotword_col[`BYTE2] = subbytes_col[`BYTE3] ;
assign rotword_col[`BYTE3] = subbytes_col[`BYTE0] ;
                          
// XOR with Rcon byte
assign rcon_xor_col[`BYTE0] = rotword_col[`BYTE0] ^ rcon_byte[sk192_count] ;
assign rcon_xor_col[`BYTE1] = rotword_col[`BYTE1] ;
assign rcon_xor_col[`BYTE2] = rotword_col[`BYTE2] ;
assign rcon_xor_col[`BYTE3] = rotword_col[`BYTE3] ;
                           
// Generate current set Key with XOR
assign sk192_curr[`COL0] = sk192_prev[`COL0] ^ rcon_xor_col ;
assign sk192_curr[`COL1] = sk192_prev[`COL1] ^ sk192_curr[`COL0] ;
assign sk192_curr[`COL2] = sk192_prev[`COL2] ^ sk192_curr[`COL1] ;
assign sk192_curr[`COL3] = sk192_prev[`COL3] ^ sk192_curr[`COL2] ;
assign sk192_curr[`COL4] = sk192_prev[`COL4] ^ sk192_curr[`COL3] ;
assign sk192_curr[`COL5] = sk192_prev[`COL5] ^ sk192_curr[`COL4] ;



endmodule
