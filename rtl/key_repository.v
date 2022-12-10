//***************************************************************************//
//
// <name of company working for>
//
// Project                    : AES Encryptor Core
// Module                     : key_repository
// Designer                   : AAK
// Date of creation           : 16 July, 2007
// Date of last modifaction   : 16 July, 2007
//
// Description                : Repository for round keys
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

module key_repository
(
  input mclk                        ,       // Master clock
  input arst_n                      ,       // active low asynchronous reset

// inputs
    input [0:255] cipherkey         ,
    input keylength128      ,
    input keylength192      ,
    input keylength256      ,
    input [3:0] round_count         ,                           // Round count from encryptor to select round key
    input start_exp             ,

// outputs
  output reg [0:127] roundkey  ,             // 128 bits round key output
    output busy_exp
);


// Interconnections
wire [0:127] rk128;
wire [0:127] rk192;
wire [0:127] rk256;
wire [3:0] rk128_count;
wire [3:0] rk192_count;
wire [3:0] rk256_count;
wire rk128_le;
wire rk192_le;
wire rk256_le;
reg start128;
reg start192;
reg start256;
wire busy128;
wire busy192;
wire busy256;

assign busy_exp = busy128 | busy192 | busy256;

always @*
begin
    start128 = 0;
    start192 = 0;
    start256 = 0;
    if (start_exp)
        if (keylength128)
            start128 = 1;
        else if (keylength192)
            start192 = 1;
        else if (keylength256)
            start256 = 1;
end

reg [0:127] rk0, rk1, rk2, rk3, rk4, rk5, rk6, rk7,
                        rk8, rk9, rk10, rk11, rk12, rk13, rk14;

key128_exp key128_exp
(
  .mclk           (mclk)                    ,
  .arst_n                   (arst_n)                ,
  .ck128_master     (cipherkey[0:127])  ,
  .start128       (start128)            ,
  .rk128                (rk128)                 ,
  .rk128_count      (rk128_count)       ,
  .rk128_le             (rk128_le)          ,
  .busy128              (busy128)
);

key192_exp key192_exp
(
  .mclk           (mclk)                    ,
  .arst_n                   (arst_n)                ,
  .ck192_master     (cipherkey[0:191])  ,
  .start192       (start192)            ,
  .rk192                (rk192)                 ,
  .rk192_count      (rk192_count)       ,
  .rk192_le             (rk192_le)          ,
  .busy192              (busy192)
);

key256_exp key256_exp
(
  .mclk           (mclk)                    ,
  .arst_n                   (arst_n)                ,
  .ck256_master     (cipherkey[0:255])  ,
  .start256       (start256)            ,
  .rk256                (rk256)                 ,
  .rk256_count      (rk256_count)       ,
  .rk256_le             (rk256_le)          ,
  .busy256              (busy256)
);





// round key registers update
always @(posedge mclk or negedge arst_n)
begin
  if (! arst_n)
    begin
        rk0  <= 0 ;     rk1  <= 0 ;     rk2  <= 0;
        rk3  <= 0 ;     rk4  <= 0 ;     rk5  <= 0;
        rk6  <= 0 ;     rk7  <= 0 ;     rk8  <= 0;
        rk9  <= 0 ;     rk10 <= 0 ;     rk11 <= 0;
        rk12 <= 0 ;     rk13 <= 0 ;     rk14 <= 0;
    end
  else
    begin
        if (rk128_le)
        begin
            case (rk128_count)
                4'd0    :   rk0  <= rk128;
                4'd1    :   rk1  <= rk128;
                4'd2    :   rk2  <= rk128;
                4'd3    :   rk3  <= rk128;
                4'd4    :   rk4  <= rk128;
                4'd5    :   rk5  <= rk128;
                4'd6    :   rk6  <= rk128;
                4'd7    :   rk7  <= rk128;
                4'd8    :   rk8  <= rk128;
                4'd9    :   rk9  <= rk128;
                4'd10   :   rk10 <= rk128;
            endcase
        end
        else if (rk192_le)
        begin
            case (rk192_count)
                4'd0    :   rk0  <= rk192;
                4'd1    :   rk1  <= rk192;
                4'd2    :   rk2  <= rk192;
                4'd3    :   rk3  <= rk192;
                4'd4    :   rk4  <= rk192;
                4'd5    :   rk5  <= rk192;
                4'd6    :   rk6  <= rk192;
                4'd7    :   rk7  <= rk192;
                4'd8    :   rk8  <= rk192;
                4'd9    :   rk9  <= rk192;
                4'd10   :   rk10 <= rk192;
                4'd11   :   rk11 <= rk192;
                4'd12   :   rk12 <= rk192;
            endcase
        end
        else if (rk256_le)
        begin
            case (rk256_count)
                4'd0    :   rk0  <= rk256;
                4'd1    :   rk1  <= rk256;
                4'd2    :   rk2  <= rk256;
                4'd3    :   rk3  <= rk256;
                4'd4    :   rk4  <= rk256;
                4'd5    :   rk5  <= rk256;
                4'd6    :   rk6  <= rk256;
                4'd7    :   rk7  <= rk256;
                4'd8    :   rk8  <= rk256;
                4'd9    :   rk9  <= rk256;
                4'd10   :   rk10 <= rk256;
                4'd11   :   rk11 <= rk256;
                4'd12   :   rk12 <= rk256;
                4'd13   :   rk13 <= rk256;
                4'd14   :   rk14 <= rk256;
            endcase
        end
    end
end


// roundkey output is selected from key registers
always @*
begin
    case (round_count)
        4'd0    :   roundkey =  rk0;
        4'd1    :   roundkey =  rk1;
        4'd2    :   roundkey =  rk2;
        4'd3    :   roundkey =  rk3;
        4'd4    :   roundkey =  rk4;
        4'd5    :   roundkey =  rk5;
        4'd6    :   roundkey =  rk6;
        4'd7    :   roundkey =  rk7;
        4'd8    :   roundkey =  rk8;
        4'd9    :   roundkey =  rk9;
        4'd10   :   roundkey =  rk10;
        4'd11   :   roundkey =  rk11;
        4'd12   :   roundkey =  rk12;
        4'd13   :   roundkey =  rk13;
        4'd14   :   roundkey =  rk14;
        default:roundkey =  rk0;
    endcase
end


endmodule
