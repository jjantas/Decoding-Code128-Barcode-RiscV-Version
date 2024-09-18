.include "code128_table.asm"

.eqv ImgInfo_fname        0
.eqv ImgInfo_hdrdat       4
.eqv ImgInfo_imdat        8
.eqv ImgInfo_width        12
.eqv ImgInfo_height       16
.eqv ImgInfo_bpp          20    # bits per pixel (either 1 or 4)
.eqv ImgInfo_lbytes       24

.eqv MAX_IMG_SIZE         11000

.eqv BMPHeader_Size       54
.eqv BMPHeader_width_offset   18
.eqv BMPHeader_height_offset  22
.eqv BMPHeader_bpp_offset     28

.eqv system_OpenFile      1024
.eqv system_ReadFile      63
.eqv system_WriteFile     64
.eqv system_CloseFile     57
.eqv system_GetTime       30
.eqv system_PrintString   4
.eqv system_PrintInt      1
.eqv system_Exit          10


.data

imgInfo: .space    28    # image descriptor

    .align 2        # word boundary alignment
dummy:        .space 2
bmpHeader:    .space BMPHeader_Size
	      .space  1024    # enough for 256 lookup table entries

    .align 2
imgData:    .space    MAX_IMG_SIZE

decoded_text:    .space    1024    # miejsce na zdekodowany tekst

ifname:        .asciz "result.bmp"


.text 

main:
# initialize image descriptor
    la a0, imgInfo
    la t0, ifname   # input file name
    sw t0, ImgInfo_fname(a0)
    la t0, bmpHeader
    sw t0, ImgInfo_hdrdat(a0)
    la t0, imgData
    sw t0, ImgInfo_imdat(a0)
    jal read_bmp
    bnez a0, main_failure
    
    la a0, imgInfo #imgInfo pointer
    la a1, decoded_text # my writing pointer
    jal decode128
    
    li a7, system_PrintString
    la a0, decoded_text
    ecall
    
    li a7, system_Exit
    ecall
    

main_failure:

    li a7, system_Exit
    ecall


read_bmp:
	mv   t0, a0	# preserve imgInfo structure pointer

# open file
	li   a7, system_OpenFile
	lw   a0, ImgInfo_fname(t0)	# file name
	li   a1, 0			# flags: 0-read file
	ecall

	blt  a0, zero, rb_error
	mv   t1, a0	# save file handle for the future

# read header
	li   a7, system_ReadFile
	lw   a1, ImgInfo_hdrdat(t0)
	li   a2, BMPHeader_Size
	ecall

# extract image information from header
	lw   a0, BMPHeader_width_offset(a1)
	sw   a0, ImgInfo_width(t0)

	# compute line size in bytes - bmp line has to be multiple of 4

	# first: pixels_in_bits = width * bpp
	lhu  t2, BMPHeader_bpp_offset(a1)	# this word is not properly aligned
	sw   t2, ImgInfo_bpp(t0)
	mul  a0, a0, t2

	# last: ((pixels_in_bits + 31) / 32 ) * 4
	addi a0, a0, 31
	srai a0, a0, 5
	slli a0, a0, 2	# linebytes = ((pixels_in_bits + 31) / 32 ) * 4

	sw   a0, ImgInfo_lbytes(t0)

	lw   a0, BMPHeader_height_offset(a1)
	sw   a0, ImgInfo_height(t0)

# read lookup table data
	li   a7, system_ReadFile
	mv   a0, t1
	lw   a1, ImgInfo_hdrdat(t0)
	addi a1, a1, BMPHeader_Size
	lw   t2, ImgInfo_bpp(t0)
	li   a2, 1
	sll  a2, a2, t2
	slli a2, a2, 2
	ecall

# read image data
	li   a7, system_ReadFile
	mv   a0, t1
	lw   a1, ImgInfo_imdat(t0)
	li   a2, MAX_IMG_SIZE
	ecall

# close file
	li   a7, system_CloseFile
	mv   a0, t1
	ecall

	mv   a0, zero
	jr   ra

rb_error:
	
	li a7, system_PrintInt
	li a0, 5 # 5 wyswietla sie jak nie dziala czytanie pliku (do usuniecia)
	ecall
	
	li a0, 1	# error opening file
	jr ra
	

decode128:
	#Arguments:
	#
	#a0 - imgInfo structure
	#a1 - writing pointer
	
	
	mv t6, a1 # preserve writing pointer
	mv t0, a0 # preserve imgInfo structure pointer
	addi sp, sp, -4
	sw s0, 0(sp) # saving s0 for later
	mv s0, ra #saving my address to go back to main
	
	lw a0, ImgInfo_imdat(t0) # a0 - address of the first byte(first 2 pixels)
	lw a1, ImgInfo_height(t0) # a1 - height of our image(in pixels)
	lw a2, ImgInfo_lbytes(t0) # a2 - amount of bytes in one line
	
	srai a1, a1, 1 # a1 - height/2
	mul a2, a2, a1 # a2 - our offset for the middle line
	add a3, a0, a2 # a3 - address of the first byte in the middle line
	
	mv t0, a3 # move it to t0
	
	lbu a0, (t0)# load whole byte to a0
	mv t3, a0 # preserve loaded byte
	srli a0, a0, 4 # shift right four times to get our 4 more significant bits
	
	mv a4, a0 # a4 - our background pixel
	
	mv a0, t3 # load preserved byte
	andi a0, a0, 0xF # clear everything except last 4 bits
	
	bne a0, a4, read_even_char # if the second pixel is already different then we have a bar
	addi t0, t0, 1 # move to the next byte

find_first_bar:
	
	lbu a0, (t0)# load whole byte to a0
	mv t3, a0 # preserve loaded byte
	srli a0, a0, 4 # shift right four times to get our 4 more significant bits
	
	bne a0, a4, read_odd_char # if its different than background then we have first bar
	
	mv a0, t3 # load preserved byte
	andi a0, a0, 0xF # clear everything except last 4 bits
	
	bne a0, a4, read_even_char # if its different we have first bar
	addi t0, t0, 1 # increment to next byte
	j find_first_bar


read_odd_char:
	#Arguments:
	#
	# t0 - address of byte where I start reading character
	

	li a6, 0x1 # a6 - CHARACTER CODE

	lbu a0, (t0)# load whole byte to a0
	srli a0, a0, 4 # shift right four times to get our 4 more significant bits
	
	mv t1, a0 # t1 - last pixel
	li t5, 5 # t5 - our loop iterator
	
read_odd_char_loop:	
	
	lbu a0, (t0)# load whole byte to a0
	andi a0, a0, 0xF # clear everything except last 4 bits
	
	beq a0, t1, recl_samethighodd # if pixels are equal dont do below actions and jump to recl
	
	slli a6, a6, 4 # if its different then charcode *16 to make place for next module
	mv t1, a0 # t1 - new last pixel
recl_samethighodd:
	addi a6, a6, 1
	addi t0, t0, 1 # increment byte address
	
	lbu a0, (t0)# load whole byte to a0
	srli a0, a0, 4 # shift right four times to get our 4 more significant bits
	
	beq a0, t1, recl_samethighodd2 # if pixels are equal dont do below actions and jump to recl
	
	slli a6, a6, 4
	mv t1, a0 # t1- new last pixel
recl_samethighodd2:
	addi a6, a6, 1
	
	addi t5, t5, -1 # decrement loop iterator
	bnez t5, read_odd_char_loop # if its not end of loop jump to the beggining of the loop
	
read_odd_char_end:
	
	mv a0, a6
	mv a1, t0
	jal find_char
	mv t0, a1
	j read_even_char

read_even_char:
	#Arguments:
	#
	# t0 - address of byte where I start reading character
	
	li a6, 0x1 # a6 - CHARACTER CODE

	lbu a0, (t0) # load whole byte to a0
	andi a0, a0, 0xF # clear everything except last 4 bits
	
	mv t1, a0 # t1 - last pixel
	addi t0, t0, 1 # increment byte address
	li t5, 5 # our loop iterator

read_even_char_loop:
	
	lbu a0, (t0)# load whole byte to a0
	mv t3, a0 # PRESERVE our byte for the next pixel 
	srli a0, a0, 4 # shift right four times to get our 4 more significant bits
	
	beq a0, t1, recl_samethighev # if pixel is the same then jump to recl_samethigh and dont do below actions
	
	slli a6, a6, 4 # if pixel is different then our character code * 16 to make place for next module
	mv t1, a0 # t1 - new last pixel
recl_samethighev:
	addi a6, a6, 1 # increment module counter
	
	mv a0, t3 # move preserved byte to a0 to get second pixel from byte
	andi a0, a0, 0xF # clear everything except last 4 bits
	
	beq a0, t1, recl_samethighev2
	
	slli a6, a6, 4 
	mv t1, a0 # t1 - new last pixel
recl_samethighev2:	
	addi a6, a6, 1
	addi t0, t0, 1
	
	addi t5, t5, -1 # decrement loop iterator
	bnez t5, read_even_char_loop # if its not end of loop jump to the beggining of the loop

read_even_char_end:

	mv a0, a6
	mv a1, t0
	jal find_char
	mv t0, a1
	j read_odd_char
	


find_char:
	# Arguments:
	#
	# a0 - character code
	# a1 - address of byte next to read
	# t6 - address where i should put my character(writing pointer)
	
	li t0, 0x211214 # start code B
	beq a0, t0, end # program is gonna work only if its code B
	la t0, code128_ascii_table    # Adres poczatku tablicy
	li t1, 0                      # Indeks tablicy
	li t5, 90   # Wstaw liczbe wpisow w tablicy
loop:
    # Odczytaj wzorzec kodu Code128 z tablicy
	lw t2, 0(t0)              # Odczytaj 32-bitowy wzorzec kodu Code128

    # Porownaj odczytane wzorce
	bne t2, a0, not_found     # Jesli wzorce sie nie zgadzaja, przejdz do etykiety "not_found"

    # Odczytaj odpowiadajacy znak ASCII z tablicy
	lb t4, 4(t0)              # Odczytaj znak ASCII z przesunieciem o 4 bajty

    # Tutaj mozesz wykorzystac znak ASCII (w rejestrze t4)
	sb t4, (t6)
	addi t6, t6, 1
    # Zakoncz petle
	jr ra

not_found:
    # Przesun wskaznik na kolejny wpis w tablicy mapowania
	addi t0, t0, 8             # Przesuniecie o 8 bajtow (kazdy wpis ma 8 bajtow: 4 na wzorzec, 4 na znak ASCII)

    # Zwieksz indeks tablicy
	addi t1, t1, 1

    # Sprawdz, czy doszlismy do konca tablicy
	blt t1, t5, loop           # Jesli indeks jest mniejszy niz liczba wpisow, kontynuuj petle
	j no_sign


no_sign:

	mv t0, s0 # move address of main to t0
	lw s0, 0(sp) # take s0 from stack
	addi sp, sp, 4 
	jr t0 # come back to main
	
end:
    # character written at writing pointer (t6) / except start_code
    # a1- address of byte next to read
    # t6 - incremented writing pointer/ except start_code
    jr ra
