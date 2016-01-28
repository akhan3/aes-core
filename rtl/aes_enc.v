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

module aes_enc
(
  input mclk                        ,       // Master clock
  input arst_n                      ,       // active low asynchronous reset

// inputs
	input keylength128		,
	input keylength192		,
	input keylength256		,
	input [0:127] plaintext			,
	input [0:255] cipherkey			,
	input plaintext_dv			,
	input cipherkey_dv			,

// outputs
  output [0:127] ciphertext  ,             // 128 bits round key output
	output ciphertext_dv			 ,
	output busy_enc						 ,
	output busy_exp
);


// Interconnections
wire [0:127] roundkey; 
wire [3:0] round_count; 
reg start_enc;
reg start_exp;

encryptor encryptor
(
  .mclk           (mclk						)	,
  .arst_n					(arst_n					)	,
  .plaintext			(plaintext			)	,
  .roundkey       (roundkey				)	,
  .start_enc   		(start_enc			)	,
	.keylength128		(keylength128		)	,
	.keylength192		(keylength192		)	,
	.keylength256		(keylength256		)	,
  .ciphertext			(ciphertext			)	,
  .ciphertext_dv	(ciphertext_dv	)	,
	.round_count		(round_count		)	,
	.busy_enc				(busy_enc				)	
);

key_repository key_repository
(
  .mclk           (mclk						)	,
  .arst_n					(arst_n					)	,
  .cipherkey      (cipherkey			)	,
  .start_exp   		(start_exp			)	,
	.keylength128		(keylength128		)	,
	.keylength192		(keylength192		)	,
	.keylength256		(keylength256		)	,
	.round_count		(round_count		)	,
  .roundkey       (roundkey				)	,
	.busy_exp				(busy_exp				)	
);


// =======================
// Master Controller
// =======================

always @*
begin
	start_enc = plaintext_dv ;
	start_exp = cipherkey_dv ;
/*
	start_enc = 0 ;
	start_exp = 0 ;
	if (~busy_enc & ~busy_exp)	// when no process is running
	begin
		if (plaintext_dv)
			start_enc = 1 ;
		else if (cipherkey_dv)
			start_exp = 1 ;
	end
*/
end


endmodule
