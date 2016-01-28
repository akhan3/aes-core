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

module key192_exp_TB;

reg         mclk          ;
reg         arst_n        ;
reg [0:191] ck192_master  ;
reg         start         ;

wire [0:127] rk192   			;
wire [3:0]   rk192_count	;
wire      	 rk192_le			;
wire         busy         ;

key192_exp  DUT
(
        .mclk			        (mclk			    )	,
				.arst_n		        (arst_n		    )	,
        .ck192_master	  	(ck192_master )	,
        .start            (start		    )	,
        .rk192   			    (rk192        )	,
        .rk192_count	    (rk192_count  )	,
        .rk192_le			    (rk192_le     )	,
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

// ck192_master input
initial
begin
  $monitor("rk192 = %h",rk192);


	#42
  ck192_master = 192'h8E73B0F7_DA0E6452_C810F32B_809079E5_62F8EAD2_522C6B7B ;
  start = 1 ;

	#10
  ck192_master = 192'hX ;
  start = 0 ;
end

initial #1000 $stop;


endmodule
