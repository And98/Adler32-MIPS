#TODO:
#1) Modificare il README, il numero di caratteri � 196563 in quanto partiamo dall'indirizzo 0x1001002c
#   e abbiamo a disposizione fino a 0x1003ffff. Capire anche come limitare l'hack di inserimento da
#   copiaincolla oppure togliere il limite alla stringa
#2) Studiare come SommaB aumenta ed eventualmente inserire unsigned e capire se serve farlo anche
#   per SommaA
#3) Inserire macro per evitare magic numbers? (Three....is the magic numba!)


.data
	str1: .asciiz "Il valore di Checksum di questa stringa �: "
	str0: .asciiz "*****Calcolatore di Checksum (Codifica Adler32)*****\nInserisci una stringa di testo:\n"
	
	
.text
__start:
##Inizio del programma

	li $v0, 4		#il codice chiamata 4 corrisponde alla scrittura a schermo di una stringa
	la $a0, str0		#sposta l'indirizzo di str0 in $a0 per utilizzare la syscall
	syscall
	
	li $v0, 8		#il codice chiamata 8 corrisponde alla lettura di una stringa
	la $a0, 0x1001002c	#$a0 = indirizzo base della stringa letta, verr� sovrascritto str0 ma non str1 che serve dopo
	li $a1, 0x1003ffff	#$a1 = lunghezza massima stringa nel .data meno 1 byte (in caso di riempimento viene riservato uno spazio per lo 0 ('null'))
	syscall
	
	la $s0, ($a0)		#carica l'indirizzo della stringa letta in $s0
	li $s1, 1 		#inizializza SommaA in $s1 con il valore 1
	li $s2, 0 		#inizializza SommaB in $s2 con il valore 0
	
	li $s6, 65521		#65521 � il maggiore numero primo contenuto in 16 bit, serve per resto 
	lui $s7, 0x0fff		#carica un numero alto per il successivo confronto con SommaB, evita overflow
	
	
loop: 
###Carica un carattere della stringa letta alla volta, calcola le somme, valuta se la stringa � conclusa

	lbu $t0, 0($s0)		#carica un carattere della stringa letta alla posizione $s0
	beq $t0, 0xa, finish	#se il valore di $t0 corrisponde a 'Invio' in ascii salta a finish
	beq $t0, $zero, finish	#se il valore di $t0 corrisponde a 'null' in ascii salta a finish
	add $s1, $s1, $t0	#SommaA = SommaA + carattere ascii
	add $s2, $s2, $s1	#SommaB = SommaB + SommaA
	
	slt $t1, $s2, $s7	#controlla se SommaB raggiunge $s7 (0x0fff0000)
	bne $t1, $zero, skip	#se SLT ha restituito 1 non calcola il resto

	move $a0, $s2		#passa SommaB come parametro alla funzione rest_calc
	jal rest_calc		#chiamata a procedura rest_calc
	move $s2, $v0		#sovrascrive SommaB col resto dato da rest_calc
	
	skip:
	addi $s0, $s0, 1	#incrementa di 1 byte l'indirizzo contenuto in $s0, passando al carattere successivo
	j loop
	
finish:
###Esegue le operazioni finali di calcolo resto, shift e stampa del risultato
	
	move $a0, $s1		#passa SommaA come parametro alla funzione rest_calc
	jal rest_calc
	move $s3, $v0		#sovrascrive SommaA col resto dato da rest_calc
	
	move $a0, $s2		#passa SommaB come parametro alla funzione rest_calc
	jal rest_calc
	sll $s4, $v0, 16	#sovrascrive SommaB col resto dato da rest_calc, con shift logico di 16
	
	add $s5, $s4, $s3	#somma i resti ottenuti, ottenendo le cifre di codifica Adler finali
	
	li $v0, 4
	la $a0, str1
	syscall
	
	li $v0, 34		#il codice chiamata 34 corrisponde alla scrittura a schermo di un numero binario in esadecimale
	move $a0, $s5
	syscall	
exit:	
	addi $v0, $zero, 10	#il codice chiamata 10 corrisponde all'uscita dal programma, che termina
	syscall
	
rest_calc:
###Calcola il resto della divisione tra un numero passato come argomento e 65521

	div $t0, $a0, $s6	#mette il risultato della divisione (intero) in $t0
	mul $t1, $s6, $t0	#mette il prodotto tra il divisore e il risultato in $t1
	sub $v0, $a0, $t1	#mette il resto in $v0
	jr $ra
