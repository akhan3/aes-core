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


reg mclk          				;
reg arst_n        				;

reg keylength128		;
reg keylength192		;
reg keylength256		;
reg [0:127] plaintext			;
reg [0:255] cipherkey			;
reg plaintext_dv			;
reg cipherkey_dv			;

wire [0:127] ciphertext  ;
wire ciphertext_dv			 ;
wire busy_enc						 ;
wire busy_exp						 ;


aes_enc  DUT
(
        .mclk			      (mclk			    	)	,
				.arst_n		      (arst_n		    	)	,
        .keylength128   (keylength128		)	,
        .keylength192  	(keylength192 	)	,
        .keylength256	  (keylength256 	)	,
        .plaintext			(plaintext 			)	,
        .cipherkey			(cipherkey 			)	,
        .plaintext_dv		(plaintext_dv 	)	,
        .cipherkey_dv   (cipherkey_dv		)	,
        .ciphertext     (ciphertext 	  )	,
        .ciphertext_dv  (ciphertext_dv	) ,
        .busy_enc    	 	(busy_enc		    )	,
        .busy_exp  			(busy_exp   	  )
);

`define HALF_PERIOD 	5 					
`define PERIOD 				`HALF_PERIOD * 2
`define TCQ 					`HALF_PERIOD / 5

// Clock generator
initial
	mclk = 1'b1;
always #`HALF_PERIOD
	mclk = ~mclk;

// Power-on reset before 1st cycle
initial
begin
			arst_n = 1'b1;
	#3	arst_n = 1'b0;
	#3	arst_n = 1'b1;
end


// ==============================================
// Main Stimulus is generated below
// ==============================================

initial
begin
			$monitor("ciphertext = %h", ciphertext);

// initialization

// Wait for Power-on reset
	#(`PERIOD)
	
// Provide the 128-bit cipherkey to expand
			keylength128 = 1 ;
			keylength192 = 0 ;
			keylength256 = 0 ;
			cipherkey[0:127] = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c ;
	#(`TCQ)
			cipherkey_dv = 1 ;
	#(`PERIOD)
			cipherkey_dv = 0 ;
	wait(! busy_exp);
	#(`PERIOD)
			$display("128-bit Key Expansion");
			$display("rk0 = %h", DUT.key_repository.rk0);
			$display("rk1 = %h", DUT.key_repository.rk1);
			$display("rk2 = %h", DUT.key_repository.rk2);
			$display("rk3 = %h", DUT.key_repository.rk3);
			$display("rk4 = %h", DUT.key_repository.rk4);
			$display("rk5 = %h", DUT.key_repository.rk5);
			$display("rk6 = %h", DUT.key_repository.rk6);
			$display("rk7 = %h", DUT.key_repository.rk7);
			$display("rk8 = %h", DUT.key_repository.rk8);
			$display("rk9 = %h", DUT.key_repository.rk9);
			$display("rk10 = %h", DUT.key_repository.rk10);

// Provide a plaintext block
			plaintext = 128'h3243f6a8_885a308d_313198a2_e0370734 ;
	#(`TCQ)
			plaintext_dv = 1 ;
	#(`PERIOD)
			plaintext_dv = 0 ;
	wait(! busy_enc);
	#(`PERIOD)
			$display("Cipher Result");
			$display("cipherkey = %h", cipherkey);
			$display("plaintext = %h", plaintext);
			$display("ciphertext = %h", ciphertext);

/*
// Provide the 192-bit cipherkey to expand
			keylength128 = 0 ;
			keylength192 = 1 ;
			keylength256 = 0 ;
			cipherkey[0:191] = 192'h8E73B0F7_DA0E6452_C810F32B_809079E5_62F8EAD2_522C6B7B ;
	#(`TCQ)
			cipherkey_dv = 1 ;
	#(`PERIOD)
			cipherkey_dv = 0 ;
	wait(! busy_exp);
	#(`PERIOD)
			$display("192-bit Key Expansion");
			$display("rk0 = %h", DUT.key_repository.rk0);
			$display("rk1 = %h", DUT.key_repository.rk1);
			$display("rk2 = %h", DUT.key_repository.rk2);
			$display("rk3 = %h", DUT.key_repository.rk3);
			$display("rk4 = %h", DUT.key_repository.rk4);
			$display("rk5 = %h", DUT.key_repository.rk5);
			$display("rk6 = %h", DUT.key_repository.rk6);
			$display("rk7 = %h", DUT.key_repository.rk7);
			$display("rk8 = %h", DUT.key_repository.rk8);
			$display("rk9 = %h", DUT.key_repository.rk9);
			$display("rk10 = %h", DUT.key_repository.rk10);
			$display("rk11 = %h", DUT.key_repository.rk11);
			$display("rk12 = %h", DUT.key_repository.rk12);

// Provide the 256-bit cipherkey to expand
			keylength128 = 0 ;
			keylength192 = 0 ;
			keylength256 = 1 ;
			cipherkey[0:255] = 256'h603deb10_15ca71be_2b73aef0_857d7781_1f352c07_3b6108d7_2d9810a3_0914dff4 ;
	#(`TCQ)
			cipherkey_dv = 1 ;
	#(`PERIOD)
			cipherkey_dv = 0 ;
	wait(! busy_exp);
	#(`PERIOD)
			$display("256-bit Key Expansion");
			$display("rk0 = %h", DUT.key_repository.rk0);
			$display("rk1 = %h", DUT.key_repository.rk1);
			$display("rk2 = %h", DUT.key_repository.rk2);
			$display("rk3 = %h", DUT.key_repository.rk3);
			$display("rk4 = %h", DUT.key_repository.rk4);
			$display("rk5 = %h", DUT.key_repository.rk5);
			$display("rk6 = %h", DUT.key_repository.rk6);
			$display("rk7 = %h", DUT.key_repository.rk7);
			$display("rk8 = %h", DUT.key_repository.rk8);
			$display("rk9 = %h", DUT.key_repository.rk9);
			$display("rk10 = %h", DUT.key_repository.rk10);
			$display("rk11 = %h", DUT.key_repository.rk11);
			$display("rk12 = %h", DUT.key_repository.rk12);
			$display("rk13 = %h", DUT.key_repository.rk13);
			$display("rk14 = %h", DUT.key_repository.rk14);
*/

// Stop the simulation
	#(`PERIOD * 2)
			$stop;
end

endmodule
