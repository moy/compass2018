	call get_m1_ptr
	let r0 r6
	call get_m2_ptr
	let r1 r6
	leti r3 3
	leti r4 4
	leti r5 2
	leti r6 0x10000	;on trouvera la multiplication ici
	call multmatrix

	leti r0 3
	leti r1 2
	leti r2 0x10000
	call blitmatrix

end:
	jump end

	;; matrice n*p : n*p cases consécutives de taille A(ici 32)
	;; les p premières lignes sont la ligne 1, les p suivantes 2…
	
	;; blitmarix : petit outil de debug : lit les cases de la matrice
	;; de taille r0*r1 en position r2 une à une et les met dans
	;; r4

	
blitmatrix:
	
	setctr a0 r2
	push 32 r7
	call mlbmult
	
	pop 32 r7
blitloop:
	readze a0 32 r0
	sub2i r2 1
	jumpif nz blitloop
	return

	;; multipliaction de matrices :
	;; r0 r1 r2 r3 r4 r5 r6 r7
	;; @0 @1 ?? n  p  q  @2
	;; écrit dans @2 la matrice produit de la matrice
	;; n*p en @0 et la matrice p*q en @1
	;; appel non-terminal ! besoin push/pop r7

	;; principe : conserver les constantes utiles sur la pile (A pour Arch)
	;; +-------+
	;; |   n   | Ces constantes serviront à réinitialiser les
	;; |  npA  | compteurs de boucle et déplacer les pointeurs
	;; |  nqA  |
	;; |   p   | une multiplication étant TRÈS coûteuse, on ne fait
	;; |  pqA  | ces opérations qu'une fois
	;; | (q-1)A|

	;; @0 et @1 sont stockées dans a0 et a1, @2 dans r6

	;; les constantes 5, 32 = 2**5, 96=3*32 dépendent de l'architecture 
	;; initialisation de la pile

	
multmatrix:
	setctr a0 r0
	setctr a1 r1
	push 32 r3

	let r0 r3
	let r1 r4
	push 32 r7
	call mlbmult
	pop 32 r7
	shift left r2 5
	push 32 r2
	let r1 r5
	push 32 r7
	call mlbmult
	pop 32 r7
	shift left r2 5
	push 32 r2

	push 32 r4

	let r0 r4
	push 32 r7
	call mlbmult
	pop 32 r7
	shift left r2 5
	push 32 r2

	sub2i r1 1
	shift left r1 5
	push 32 r1

columns_loop:
lines_loop:
	leti r2 0
scalar_prod_loop:
	readze a0 32 r0
	readze a1 32 r1

	push 32 r7
	call mlbsum
	pop 32 r7

	getctr a1 r0
	pop 32 r1
	push 32 r1
	add2 r0 r1
	setctr a1 r0
	sub2i r4 1
	jumpif nz scalar_prod_loop

	getctr a1 r0
	setctr a1 r6
	write a1 32 r2

	pop 32 r1
	add2 r6 r1
	add2i r6 32
	pop 32 r2

	sub2 r0 r2
	setctr a1 r0

	pop 32 r4
	push 32 r4
	push 32 r2
	push 32 r1

	sub2i r3 1
	jumpif nz lines_loop

	add2i r0 32
	setctr a1 r0

	getctr sp r0
	add2i r0 96
	setctr sp r0

	pop 32 r1
	sub2 r6 r1
	add2i r6 32
	
	getctr a0 r3
	pop 32 r2

	sub2 r3 r2
	setctr a0 r3
	pop 32 r3
	push 32 r3
	push 32 r2
	push 32 r1
	sub2i r0 96
	setctr sp r0

	sub2i r5 1
	jumpif nz columns_loop

	return

get_m1_ptr:
	getctr pc r6
	add2i r6 24
	return

	.const 384 #000000000000000000000000000000010000000000000000000000000000001000000000000000000000000000000011000000000000000000000000000001000000000000000000000000000000010100000000000000000000000000000110000000000000000000000000000001110000000000000000000000000000100000000000000000000000000000001001000000000000000000000000000010100000000000000000000000000000101100000000000000000000000000001100

get_m2_ptr:
	getctr pc r6
	add2i r6 24
	return
	.const 256 #0000000000000000000000000000110100000000000000000000000000001110000000000000000000000000000011110000000000000000000000000001000000000000000000000000000000010001000000000000000000000000000100100000000000000000000000000001001100000000000000000000000000010100

mlbmult:
	push 32 r0
	push 32 r1
	leti r2 0
	push 32 r7
	call mlbsum
	pop 32 r7
	pop 32 r1
	pop 32 r0
	return

mlbsum:
	shift right r0 1
	jumpif nc mlbsk
	add2 r2 r1
mlbsk:
	add2i r0 0
	shift left r1 1
	cmpi r0 0
	jumpif nz mlbsum
	return

	;;         \  \ \'.' /
	;;          \  `./  /
	;;           \     /
	;;           |    .|
	;;           |:..::|
	;;           |:::::| npA
	;;           |:::::|
	;;           |:::::|
	;;           ):::::(
	;;           `.:::.'
	;;             """
