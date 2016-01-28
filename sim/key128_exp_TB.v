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

module key128_exp_TB;

reg         mclk          ;
reg         arst_n        ;
reg [0:127] ck128_master  ;
reg         start         ;

wire [0:127] rk128   			;
wire [3:0]   rk128_count	;
wire      	 rk128_le			;
wire         busy         ;

key128_exp  DUT
(
        .mclk			        (mclk			    )	,
				.arst_n		        (arst_n		    )	,
        .ck128_master	  	(ck128_master )	,
        .start            (start		    )	,
        .rk128   			    (rk128        )	,
        .rk128_count	    (rk128_count  )	,
        .rk128_le			    (rk128_le     )	,
        .busy             (busy         )	
);


// Power-on reset
initial
begin
       arst_n = 1'b1;
	#40  arst_n = 1'b0;
	#100 arst_n = 1'b1;
       start = 0;
end

// Clock generator
initial     mclk = 1'b1;
always  #50 mclk = ~mclk;

// ck128_master input
initial
begin
  $monitor("rk128 = %h",rk128);
  
	#420
  ck128_master = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c ;
  start = 1 ;

	#100
  ck128_master = 128'hX ;
  start = 0 ;
end

initial #3000 $stop;


endmodule
