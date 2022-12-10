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

module key_repository_TB;


reg mclk;
reg arst_n;

reg [0:255] cipherkey;
reg keylength128;
reg keylength192;
reg keylength256;
reg [3:0] round_count           ;                           // Round count from encryptor to select round key
reg start_exp;

wire [0:127] roundkey       ;             // 128 bits round key output
wire busy_exp;


key_repository  DUT
(
        .mclk                 (mclk             )   ,
                .arst_n           (arst_n           )   ,
        .cipherkey          (cipherkey      )   ,
        .keylength128   (keylength128   )   ,
        .keylength192   (keylength192 ) ,
        .keylength256     (keylength256 )   ,
        .round_count        (round_count  ) ,
        .start_exp      (start_exp    ) ,
        .roundkey       (roundkey     ) ,
        .busy_exp       (busy_exp     )
);


// Clock generator
initial     mclk = 1'b1;
always  #5 mclk = ~mclk;

// Power-on reset
initial
begin
            arst_n = 1'b1;
    #4  arst_n = 1'b0;
    #4  arst_n = 1'b1;
end

// init
initial
begin
    cipherkey = 0;
    start_exp = 0;
end

initial
begin
    #10

// Provide the 128-bit cipherkey to expand
    #1
            cipherkey[0:127] = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;
            start_exp = 1;
            keylength128 = 1;
            keylength192 = 0;
            keylength256 = 0;
    #10
            cipherkey = 'hx;
            start_exp = 0;
    wait(! busy_exp) #10
            $display("128-bit Key Expansion");
            $display("rk0 = %h", DUT.rk0);
            $display("rk1 = %h", DUT.rk1);
            $display("rk2 = %h", DUT.rk2);
            $display("rk3 = %h", DUT.rk3);
            $display("rk4 = %h", DUT.rk4);
            $display("rk5 = %h", DUT.rk5);
            $display("rk6 = %h", DUT.rk6);
            $display("rk7 = %h", DUT.rk7);
            $display("rk8 = %h", DUT.rk8);
            $display("rk9 = %h", DUT.rk9);
            $display("rk10 = %h", DUT.rk10);

// Provide the 192-bit cipherkey to expand
    #1
            cipherkey[0:191] = 192'h8E73B0F7_DA0E6452_C810F32B_809079E5_62F8EAD2_522C6B7B;
            start_exp = 1;
            keylength128 = 0;
            keylength192 = 1;
            keylength256 = 0;
    #10
            cipherkey = 'hx;
            start_exp = 0;
    wait(! busy_exp) #10
            $display("192-bit Key Expansion");
            $display("rk0 = %h", DUT.rk0);
            $display("rk1 = %h", DUT.rk1);
            $display("rk2 = %h", DUT.rk2);
            $display("rk3 = %h", DUT.rk3);
            $display("rk4 = %h", DUT.rk4);
            $display("rk5 = %h", DUT.rk5);
            $display("rk6 = %h", DUT.rk6);
            $display("rk7 = %h", DUT.rk7);
            $display("rk8 = %h", DUT.rk8);
            $display("rk9 = %h", DUT.rk9);
            $display("rk10 = %h", DUT.rk10);
            $display("rk11 = %h", DUT.rk11);
            $display("rk12 = %h", DUT.rk12);

// Provide the 256-bit cipherkey to expand
    #1
            cipherkey[0:255] = 256'h603deb10_15ca71be_2b73aef0_857d7781_1f352c07_3b6108d7_2d9810a3_0914dff4;
            start_exp = 1;
            keylength128 = 0;
            keylength192 = 0;
            keylength256 = 1;
    #10
            cipherkey = 'hx;
            start_exp = 0;
    wait(! busy_exp) #10
            $display("256-bit Key Expansion");
            $display("rk0 = %h", DUT.rk0);
            $display("rk1 = %h", DUT.rk1);
            $display("rk2 = %h", DUT.rk2);
            $display("rk3 = %h", DUT.rk3);
            $display("rk4 = %h", DUT.rk4);
            $display("rk5 = %h", DUT.rk5);
            $display("rk6 = %h", DUT.rk6);
            $display("rk7 = %h", DUT.rk7);
            $display("rk8 = %h", DUT.rk8);
            $display("rk9 = %h", DUT.rk9);
            $display("rk10 = %h", DUT.rk10);
            $display("rk11 = %h", DUT.rk11);
            $display("rk12 = %h", DUT.rk12);
            $display("rk13 = %h", DUT.rk13);
            $display("rk14 = %h", DUT.rk14);

    #10 $stop;
end

endmodule
