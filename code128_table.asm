
.data
.align 2


code128_ascii_table:
    # Wzorzec kodu Code128 SetCodeB (11-bitowy) | Znak ASCII
    .word 0x212222, ' '   # Spacja
    .word 0x222122, '!'   # !
    .word 0x222221, '"'   # "
    .word 0x121223, '#'   # #
    .word 0x121322, '$'   # $
    .word 0x131222, '%'   # %
    .word 0x122213, '&'   # &
    .word 0x132212, '('   # (
    .word 0x221213, ')'   # )
    .word 0x221312, '*'   # *
    .word 0x231212, '+'   # +
    .word 0x112232, ','   # ,
    .word 0x122132, '-'   # -
    .word 0x122231, '.'   # .
    .word 0x113222, '/'   # /
    .word 0x123122, '0'   # 0
    .word 0x123221, '1'   # 1
    .word 0x223211, '2'   # 2
    .word 0x221132, '3'   # 3
    .word 0x221231, '4'   # 4
    .word 0x213212, '5'   # 5
    .word 0x223112, '6'   # 6
    .word 0x312131, '7'   # 7
    .word 0x311222, '8'   # 8
    .word 0x321122, '9'   # 9
    .word 0x321221, ':'   # :
    .word 0x312212, ';'   # ;
    .word 0x322112, '<'   # <
    .word 0x322211, '='   # =
    .word 0x212123, '>'   # >
    .word 0x212321, '?'   # ?
    .word 0x232121, '@'   # @
    .word 0x111323, 'A'   # A
    .word 0x131123, 'B'   # B
    .word 0x131321, 'C'   # C
    .word 0x112313, 'D'   # D
    .word 0x132113, 'E'   # E
    .word 0x132311, 'F'   # F
    .word 0x211313, 'G'   # G
    .word 0x231113, 'H'   # H
    .word 0x231311, 'I'   # I
    .word 0x112133, 'J'   # J
    .word 0x112331, 'K'   # K
    .word 0x132131, 'L'   # L
    .word 0x113123, 'M'   # M
    .word 0x113321, 'N'   # N
    .word 0x133121, 'O'   # O
    .word 0x313121, 'P'   # P
    .word 0x211331, 'Q'   # Q
    .word 0x231131, 'R'   # R
    .word 0x213113, 'S'   # S
    .word 0x213311, 'T'   # T
    .word 0x213131, 'U'   # U
    .word 0x311123, 'V'   # V
    .word 0x311321, 'W'   # W
    .word 0x331121, 'X'   # X
    .word 0x312113, 'Y'   # Y
    .word 0x312311, 'Z'   # Z
    .word 0x332111, '['   # [
    .word 0x314111, '\\'  # \
    .word 0x221411, ']'   # ]
    .word 0x431111, '^'   # ^
    .word 0x111224, '_'   # _
    .word 0x111422, '`'   # `
    .word 0x121124, 'a'  # Przyk³adowy wzorzec dla litery "a"
    .word 0x121421, 'b'  # Przyk³adowy wzorzec dla litery "b"
    .word 0x141122, 'c'  # Przyk³adowy wzorzec dla litery "c"
    .word 0x141221, 'd'
    .word 0x112214, 'e'
    .word 0x112412, 'f'
    .word 0x122114, 'g'
    .word 0x122411, 'h'
    .word 0x142112, 'i'
    .word 0x142211, 'j'
    .word 0x241211, 'k'
    .word 0x221114, 'l'
    .word 0x413111, 'm'
    .word 0x241112, 'n'
    .word 0x134111, 'o' 
    .word 0x111242, 'p'
    .word 0x121142, 'q'
    .word 0x121241, 'r'
    .word 0x114212, 's'
    .word 0x124112, 't'
    .word 0x124211, 'u'
    .word 0x411212, 'v'
    .word 0x421112, 'w'
    .word 0x421211, 'x'
    .word 0x212141, 'y'
    .word 0x214121, 'z'
