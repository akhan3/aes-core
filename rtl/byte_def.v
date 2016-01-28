//***************************************************************************//
//
// SUPARCO/SRDC-K/IPS
//
// Project                    : AES Encryptor Core
// Module                     : 
// Designer                   : AAK
// Date of creation           : 16 July, 2007
// Date of last modifaction   : 16 July, 2007
//
// Description                : State Matrix definitions
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

/*
 ---------------------------------------------------------------
|       | Col0 | Col1 | Col2 | Col3 | Col4 | Col5 | Col6 | Col7 |   
|-------|------|------|------|------|------|------|------|------|
| Row0  |  00  |  01  |  02  |  03  |  04  |  05  |  06  |  07  |
| Row1  |  10  |  11  |  12  |  13  |  14  |  15  |  16  |  17  |
| Row2  |  20  |  21  |  22  |  23  |  24  |  25  |  26  |  27  |
| Row3  |  30  |  31  |  32  |  33  |  34  |  35  |  36  |  37  |
 ---------------------------------------------------------------
*/                                                            

// Column 0
`define	BYTE00 0:7			
`define	BYTE10 8:15			
`define	BYTE20 16:23		
`define	BYTE30 24:31		

// Column 1
`define	BYTE01 32:39		
`define	BYTE11 40:47		
`define	BYTE21 48:55		
`define	BYTE31 56:63		

// Column 2
`define	BYTE02 64:71		
`define	BYTE12 72:79		
`define	BYTE22 80:87		
`define	BYTE32 88:95		

// Column 3
`define	BYTE03 96:103
`define	BYTE13 104:111
`define	BYTE23 112:119
`define	BYTE33 120:127

// Column 4
`define	BYTE04 128:135
`define	BYTE14 136:143
`define	BYTE24 144:151
`define	BYTE34 152:159

// Column 5
`define	BYTE05 160:167
`define	BYTE15 168:175
`define	BYTE25 176:183
`define	BYTE35 184:191

// Column 6
`define	BYTE06 192:199
`define	BYTE16 200:207
`define	BYTE26 208:215
`define	BYTE36 216:223

// Column 7
`define	BYTE07 224:231
`define	BYTE17 232:239
`define	BYTE27 240:247
`define	BYTE37 248:255

// All Columns
`define	COL0 0:31
`define	COL1 32:63
`define	COL2 64:95
`define	COL3 96:127
`define	COL4 128:159
`define	COL5 160:191
`define	COL6 192:223
`define	COL7 224:255

// All Bytes
`define	BYTE0 0:7
`define	BYTE1 8:15
`define	BYTE2 16:23
`define	BYTE3 24:31
