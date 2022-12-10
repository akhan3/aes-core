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

module aes_enc_TB;


reg mclk;
reg arst_n;

reg keylength128;
reg keylength192;
reg keylength256;
reg [0:127] plaintext;
reg [0:255] cipherkey;
reg plaintext_dv;
reg cipherkey_dv;

wire [0:127] ciphertext;
wire ciphertext_dv;
wire busy_enc;
wire busy_exp;


aes_enc  DUT
(
        .mclk                 (mclk                 )   ,
                .arst_n           (arst_n               )   ,
        .keylength128   (keylength128       )   ,
        .keylength192   (keylength192   )   ,
        .keylength256     (keylength256     )   ,
        .plaintext          (plaintext          )   ,
        .cipherkey          (cipherkey          )   ,
        .plaintext_dv       (plaintext_dv   )   ,
        .cipherkey_dv   (cipherkey_dv       )   ,
        .ciphertext     (ciphertext       ) ,
        .ciphertext_dv  (ciphertext_dv  ) ,
        .busy_enc           (busy_enc           )   ,
        .busy_exp           (busy_exp         )
);

`define HALF_PERIOD     5
`define PERIOD              `HALF_PERIOD * 2
`define TCQ                     `HALF_PERIOD / 5

// Clock generator
initial
    mclk = 1'b1;
always #`HALF_PERIOD
    mclk = ~mclk;

// Power-on reset before 1st cycle
initial
begin
            arst_n = 1'b1;
    #3  arst_n = 1'b0;
    #3  arst_n = 1'b1;
end


// ==============================================
// Main Stimulus is generated below
// ==============================================

`include "test_vectors.v"
    integer FILE1;

initial
begin
    FILE1 = $fopen("sim_results.log") | 1'b1;

// initialization

// Wait for Power-on reset
    #(`PERIOD)

// Provide the 128-bit cipherkey to expand
            keylength128 = 1;
            keylength192 = 0;
            keylength256 = 0;
            cipherkey[0:127] = `CK128;
    #(`TCQ)
            cipherkey_dv = 1;
    #(`PERIOD)
            cipherkey_dv = 0;
    wait(! busy_exp);
    #(`PERIOD)

// Provide a plaintext block to encrypt
            plaintext = `PT;
    #(`TCQ)
            plaintext_dv = 1;
    #(`PERIOD)
            plaintext_dv = 0;
    wait(! busy_enc);
    #(`PERIOD)
            $fdisplay(FILE1, "\nCipher Result");
            $fdisplay(FILE1, "===============");
            $fdisplay(FILE1, "plaintext  = %h", `PT);
            $fdisplay(FILE1, "cipherkey  = %h", `CK128);
            $fdisplay(FILE1, "ciphertext = %h", ciphertext);
            $fdisplay(FILE1, "===============\n");


// Provide the 192-bit cipherkey to expand
            keylength128 = 0;
            keylength192 = 1;
            keylength256 = 0;
            cipherkey[0:191] = `CK192;
    #(`TCQ)
            cipherkey_dv = 1;
    #(`PERIOD)
            cipherkey_dv = 0;
    wait(! busy_exp);
    #(`PERIOD)

// Provide a plaintext block to encrypt
            plaintext = `PT;
    #(`TCQ)
            plaintext_dv = 1;
    #(`PERIOD)
            plaintext_dv = 0;
    wait(! busy_enc);
    #(`PERIOD)
            $fdisplay(FILE1, "\nCipher Result");
            $fdisplay(FILE1, "===============");
            $fdisplay(FILE1, "plaintext  = %h", `PT);
            $fdisplay(FILE1, "cipherkey  = %h", `CK192);
            $fdisplay(FILE1, "ciphertext = %h", ciphertext);
            $fdisplay(FILE1, "===============\n");


// Provide the 256-bit cipherkey to expand
            keylength128 = 0;
            keylength192 = 0;
            keylength256 = 1;
            cipherkey[0:255] = `CK256;
    #(`TCQ)
            cipherkey_dv = 1;
    #(`PERIOD)
            cipherkey_dv = 0;
    wait(! busy_exp);
    #(`PERIOD)

// Provide a plaintext block to encrypt
            plaintext = `PT;
    #(`TCQ)
            plaintext_dv = 1;
    #(`PERIOD)
            plaintext_dv = 0;
    wait(! busy_enc);
    #(`PERIOD)
            $fdisplay(FILE1, "\nCipher Result");
            $fdisplay(FILE1, "===============");
            $fdisplay(FILE1, "plaintext  = %h", `PT);
            $fdisplay(FILE1, "cipherkey  = %h", `CK256);
            $fdisplay(FILE1, "ciphertext = %h", ciphertext);
            $fdisplay(FILE1, "===============\n");


// Stop the simulation
    #(`PERIOD * 2)
            $stop;
end

endmodule
