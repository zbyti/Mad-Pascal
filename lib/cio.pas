unit cio;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: CIO interface
 @version: 1.0

 @description:

*)


{

Cls
Get
Opn
Put
XIO

}

interface

	procedure Opn(chn, ax1, ax2: byte; device: PByte); assembler;
	procedure Cls(chn: byte); assembler;
	function Get(chn: byte): byte; assembler;
	procedure Put(chn, a: byte): assembler;
	procedure XIO(chn, cmd, ax1, ax2: byte); assembler;
	
implementation


procedure Opn(chn, ax1, ax2: byte; device: PByte); assembler;
asm
{	txa:pha

	lda chn
	:4 asl @
	tax

	lda #$03		;komenda: OPEN
	sta iccmd,x

	inw device		;omin bajt z dlugoscia STRING-a

	lda device		;adres nazwy pliku
	sta icbufa,x
	lda device+1
	sta icbufa+1,x

	lda ax1			;kod dostepu: $04 odczyt, $08 zapis, $09 dopisywanie, $0c odczyt/zapis, $0d odczyt/dopisywanie
	sta icax1,x

	lda ax2			;dodatkowy parametr, $00 jest zawsze dobre
	sta icax2,x

	jsr ciov

	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


procedure Cls(chn: byte); assembler;
asm
{	txa:pha

	lda chn
	:4 asl @
	tax

	lda #$0c		;komenda: CLOSE
	sta iccmd,x

	jsr ciov

	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


function Get(chn: byte): byte; assembler;
asm
{	txa:pha
 
	lda chn
	:4 asl @
	tax
 
	lda #7		;get char command
	sta iccmd,x

	lda #$00	;zero out the unused
	sta icbufl,x	;store in accumulator
	sta icbufh,x	;...after CIOV jump
	jsr ciov

	sty MAIN.SYSTEM.IOResult
	
	sta Result

	pla:tax
};
end;


procedure Put(chn, a: byte): assembler;
asm
{	txa:pha
 
	lda chn
	:4 asl @
	tax
 
	lda #11		;put char command
	sta iccmd,x

	lda #$00	;zero out the unused
	sta icbufl,x	;store in accumulator
	sta icbufh,x	;...after CIOV jump
	
	lda a
	jsr ciov

	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


procedure XIO(chn, cmd, ax1, ax2: byte); assembler;
asm
{	txa:pha

	lda chn
	:4 asl @
	tax

	lda cmd
	sta iccmd,x

	lda ax1
	sta icax1,x

	lda ax2
	sta icax2,x

	jsr ciov

	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


end.