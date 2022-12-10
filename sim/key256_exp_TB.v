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

`timescale 1ns/1ns

module key256_exp_TB;

reg         mclk;
reg         arst_n;
reg [0:255] ck256_master;
reg         start;

wire [0:127] rk256;
wire [3:0]   rk256_count;
wire         rk256_le;
wire         busy;

key256_exp  DUT
(
        .mclk                   (mclk               )   ,
                .arst_n             (arst_n         )   ,
        .ck256_master       (ck256_master ) ,
        .start            (start            )   ,
        .rk256                  (rk256        ) ,
        .rk256_count        (rk256_count  ) ,
        .rk256_le               (rk256_le     ) ,
        .busy             (busy         )
);


// Power-on reset
initial
begin
      arst_n = 1'b1;
    #4  arst_n = 1'b0;
    #10 arst_n = 1'b1;
      start = 0;
end

// Clock generator
initial    mclk = 1'b1;
always  #5 mclk = ~mclk;

// ck256_master input
initial
begin
  $monitor("rk256 = %h",rk256);

    #42
  ck256_master = 256'h603deb10_15ca71be_2b73aef0_857d7781_1f352c07_3b6108d7_2d9810a3_0914dff4;
  start = 1;

    #10
  ck256_master = 256'hX;
  start = 0;
end

initial #1000 $stop;


endmodule
