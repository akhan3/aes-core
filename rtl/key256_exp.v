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

module key256_exp
(
  input mclk                      ,     // Master clock
  input arst_n                    ,     // active low asynchronous reset

// inputs
  input [0:255] ck256_master            ,       // 256 bits Cipher Key input
  input         start256             ,      // load enable signal for the cipher key

// outputs
  output reg [0:127] rk256              ,       // 128 bits Round Key output
  output reg [3:0]   rk256_count    ,
  output reg         rk256_le           ,
  output reg         busy256
);


// Interconnections
reg  [0:255] sk256_prev;      // Previous set Key
wire [0:255] sk256_curr;      // Transformed current set key
reg  [3:0]   sk256_count;
reg          sbox_en;
reg          sbox_mid_en;

// =======================
// ASMD implementation
// =======================

//// state machine
reg [4:0] state, nextState;
parameter IDLE = 5'b00001 ,
          LOD0 = 5'b00010 ,
          LDN0 = 5'b00100 ,
          LOD1 = 5'b01000 ,
          LDN1 = 5'b10000;

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
      if (start256)
        nextState = LOD0;
      else
        nextState = IDLE;
    LOD0:
      if (rk256_count != 4'd14)
                nextState = LDN0;
      else
        nextState = IDLE;
    LDN0:
        nextState = LOD1;
    LOD1:
        nextState = LDN1;
    LDN1:
        nextState = LOD0;
    default:
      nextState = IDLE;
  endcase
end

//// register transfers
always @(posedge mclk or negedge arst_n)
begin
  if (! arst_n)
  begin
    sk256_prev <= 0;
    rk256_count <= 0;
  end
  else
  begin
    case (state)
      IDLE:
        if (start256)
        begin
          sk256_prev <= ck256_master;
          rk256_count <= 4'd0;
        end

      LDN0:
            begin
        sk256_prev[0:127] <= sk256_curr[0:127];
                rk256_count <= rk256_count + 1'b1;
            end

      LDN1:
            begin
        sk256_prev[128:255] <= sk256_curr[128:255];
                rk256_count <= rk256_count + 1'b1;
            end

    endcase
  end
end

//// Combinational outputs
always @*
begin
  sbox_en = 0;
    sbox_mid_en = 0;
  rk256_le = 0;
  busy256 = 0;
  rk256 = 128'dx;
  sk256_count = (rk256_count >> 1'b1) + 1'b1;

  case (state)
        IDLE:
            if (start256)
                busy256 = 1;
        LOD0:
        begin
            sbox_en = 1;
            rk256_le = 1;
            busy256 = 1;
            rk256 = sk256_prev[0:127];
        end
        LDN0:
            busy256 = 1;
        LOD1:
        begin
            sbox_mid_en = 1;
            rk256_le = 1;
            busy256 = 1;
            rk256 = sk256_prev[128:255];
        end
        LDN1:
            busy256 = 1;
  endcase
end


// =================================
// Key Expansion Transformations
// =================================

wire [0:31] subbytes_col;
wire [0:31] rotword_col;
wire [0:31] rcon_xor_col;
wire [0:31] subbytes_mid_col;

// Round Constant Word Array
wire [0:7] rcon_byte [1:10];
assign rcon_byte[1] = 8'h01;
assign rcon_byte[2] = 8'h02;
assign rcon_byte[3] = 8'h04;
assign rcon_byte[4] = 8'h08;
assign rcon_byte[5] = 8'h10;
assign rcon_byte[6] = 8'h20;
assign rcon_byte[7] = 8'h40;
assign rcon_byte[8] = 8'h80;
assign rcon_byte[9] = 8'h1B;
assign rcon_byte[10]= 8'h36;

// Sub Bytes Transformation
sbox sbox0 (mclk, sbox_en, sk256_prev[`BYTE07], subbytes_col[`BYTE0]);
sbox sbox1 (mclk, sbox_en, sk256_prev[`BYTE17], subbytes_col[`BYTE1]);
sbox sbox2 (mclk, sbox_en, sk256_prev[`BYTE27], subbytes_col[`BYTE2]);
sbox sbox3 (mclk, sbox_en, sk256_prev[`BYTE37], subbytes_col[`BYTE3]);

// Rotate Word Transformation
assign rotword_col[`BYTE0] = subbytes_col[`BYTE1];
assign rotword_col[`BYTE1] = subbytes_col[`BYTE2];
assign rotword_col[`BYTE2] = subbytes_col[`BYTE3];
assign rotword_col[`BYTE3] = subbytes_col[`BYTE0];

// XOR with Rcon byte
assign rcon_xor_col[`BYTE0] = rotword_col[`BYTE0] ^ rcon_byte[sk256_count];
assign rcon_xor_col[`BYTE1] = rotword_col[`BYTE1];
assign rcon_xor_col[`BYTE2] = rotword_col[`BYTE2];
assign rcon_xor_col[`BYTE3] = rotword_col[`BYTE3];

// Generate current set Key's first four columns with XOR
assign sk256_curr[`COL0] = sk256_prev[`COL0] ^ rcon_xor_col;
assign sk256_curr[`COL1] = sk256_prev[`COL1] ^ sk256_curr[`COL0];
assign sk256_curr[`COL2] = sk256_prev[`COL2] ^ sk256_curr[`COL1];
assign sk256_curr[`COL3] = sk256_prev[`COL3] ^ sk256_curr[`COL2];

// Mid Sub Bytes Transformation
sbox sbox4 (mclk, sbox_mid_en, sk256_prev[`BYTE03], subbytes_mid_col[`BYTE0]);
sbox sbox5 (mclk, sbox_mid_en, sk256_prev[`BYTE13], subbytes_mid_col[`BYTE1]);
sbox sbox6 (mclk, sbox_mid_en, sk256_prev[`BYTE23], subbytes_mid_col[`BYTE2]);
sbox sbox7 (mclk, sbox_mid_en, sk256_prev[`BYTE33], subbytes_mid_col[`BYTE3]);

// Generate current set Key's last four columns with XOR
assign sk256_curr[`COL4] = sk256_prev[`COL4] ^ subbytes_mid_col;
assign sk256_curr[`COL5] = sk256_prev[`COL5] ^ sk256_curr[`COL4];
assign sk256_curr[`COL6] = sk256_prev[`COL6] ^ sk256_curr[`COL5];
assign sk256_curr[`COL7] = sk256_prev[`COL7] ^ sk256_curr[`COL6];


endmodule
