#TODO:
#1) Scoprire il limite massimo di caratteri per la stringa inserita (e modificare il README di conseguenza), dovrebbe essere 1.878.982.611 (0x6ffeffd3) in quanto partiamo dall'indirizzo 0x1001002c
#   e abbiamo a disposizione fino a 0x80000000 (?). Fatto sta che la stringa supererebbe il GB e � difficile generarla e maneggiarla
#2) Utilizzare di pi� i registri $s, ci sono, usiamoli
#) Inserire macro per evitare magic numbers?


.data
	str1: .asciiz "Il valore di Checksum di questa stringa �: "
	str0: .asciiz "*****Calcolatore di Checksum (Codifica Adler32)*****\nInserisci una stringa di testo:\n"
	
	
.text
__start:
	li $v0, 4		#il codice chiamata 4 corrisponde alla scrittura a schermo di una stringa
	la $a0, str0		#sposta l'indirizzo di str0 in $a0 per utilizzare la syscall
	syscall
	
	li $v0, 8		#il codice chiamata 8 corrisponde alla lettura di una stringa
	li $a0, 0x1001002c	#$a0 = indirizzo base della stringa letta, verr� sovrascritto str0 ma non str1 che serve dopo
	li $a1, 0x6ffeffd3		#$a1 = lunghezza massima stringa meno 1 (in caso di riempimento viene riservato uno spazio per lo 0 ('null'))
	syscall
	
	la $t0, ($a0)		#carica l'indirizzo della stringa letta in $t0
	li $t2, 1 		#inizializza SommaA in $t2 con il valore 1
	li $t3, 0 		#inizializza SommaB in $t3 con il valore 0
	
	lui $t4, 0x0fff		#carica 0x0fff0000 (circa 250 milioni) in $t4 per il successivo confronto con SommaB
	
	j loop
	
loop: 
###Carica un carattere della stringa letta alla volta e valuta se la stringa � conclusa

	lbu $t1, 0($t0)		#carica un carattere della stringa letta alla posizione $t1
	beq $t1, 0xa, finish	#se il valore di $t1 corrisponde a 'Invio' in ascii salta a finish
	beq $t1, $zero, finish	#se il valore di $t1 corrisponde a 'null' in ascii salta a finish
	add $t2, $t2, $t1	#SommaA = SommaA + carattere ascii
	add $t3, $t3, $t2	#SommaB = SommaB + SommaA
	
	slt $t5, $t3, $t4		#controlla se $t3 raggiunge $t4 (0x0fff0000)
	bne $t5, 1, prerest_calc	#se SLTI ha restituito 1 salta a rest_calc
	
	addi $t0, $t0, 1	#incrementa di 1 byte l'indirizzo contenuto in $t0, passando al carattere successivo
	
	j loop
	
finish:
###Esegue le operazioni finali di calcolo resto, shift e stampa del risultato

	move $s0, $t2		#salva le somme finali in registri non riscrivibili
	move $s1, $t3
	
	move $a0, $s0		#sposta la prima somma in un registro parametro per funzione
	jal rest_calc
	move $s2, $v0		#salva il resto ottenuto in un registro non riscrivibile
	
	move $a0, $s1		#sposta la seconda somma in un registro parametro per funzione
	jal rest_calc
	sll $s3, $v0, 16	#salva il resto ottenuto, con shift logico di 16, in un registro non riscrivibile 
	
	add $s4, $s3, $s2	#somma i resti ottenuti
	
	li $v0, 4
	la $a0, str1
	syscall
	
	li $v0, 34		#il codice chiamata 34 corrisponde alla scrittura a schermo di un numero binario in esadecimale
	move $a0, $s4
	syscall
	
	j exit
	
prerest_calc:
###Tramite rest_calc calcola il resto per ridurre la dimensione di SommaB e torna a loop

	move $a0, $t3 		#copia SommaB in $a0
	jal rest_calc
	move $t3, $v0		#sovrascrive SommaB col resto dato da rest_calc
	li $t5, 0		#resetta il flag alzato da SLT
	addi $t0, $t0, 1	#incrementa di 1 byte l'indirizzo contenuto in $t0, passando al carattere successivo
	
	j loop			#torna a loop, continuando dall'iterazione successiva
	
rest_calc:
###Calcola il resto della divisione tra un numero passato come argomento e 65521

	li $t6, 65521		#65521 � il maggiore numero primo contenuto in 16 bit 
	div $t7, $a0, $t6	#mette il risultato della divisione (intero) in $t1
	mul $t8, $t6, $t7	#mette il prodotto tra il divisore e il risultato in $t2
	sub $v0, $a0, $t8	#mette il resto in $v0
	jr $ra
	
exit:
	addi $v0, $zero, 10	#il codice chiamata 10 corrisponde all'uscita dal programma
	syscall
