# Adler32 MIPS
Implementazione dell'algoritmo Adler-32 in Assembly MIPS realizzata da @And98 e @pusi77 per un progetto relativo al corso universitario di Calcolatori Elettronici.

# L'algoritmo Adler-32
## Introduzione
L'Adler-32 è un algoritmo per il calcolo del *checksum* (o somma di controllo) a 32 bit sviluppato da Mark Adler nel 1995. [Qui](https://en.wikipedia.org/wiki/Adler-32) si possono trovare maggiori informazioni.
## Algoritmo
Come si può leggere [qui](https://software.intel.com/en-us/articles/fast-computation-of-adler32-checksums) ci sono metodi di implementazione differenti per il momento in cui viene eseguito l'operatore modulo della divisione. I principali sono il calcolo del modulo ad ogni iterazione (opzione più lenta e meno efficiente, ma più sicura) oppure una volta calcolate le somme finali (metodo migliore per le prestazioni, ma vulnerabile a problemi in caso una delle due somme diventi troppo grande in modulo). <br/><br/>
La nostra è un'implementazione ibrida, come si potrà evincere poco più in basso nel paragrafo chiamato **Funzionamento**.<br/>
Data una stringa di byte D con lunghezza n, data A la somma del valore Ascii di ogni byte più 1 e B la somma dei valori di A per ogni iterazione:
```
A = 1 + D1 + D2 + ... + Dn (mod 65521)

B = (1 + D1) + (1 + D1 + D2) + ... + (1 + D1 + D2 + ... + Dn) (mod 65521)
  = n×D1 + (n−1)×D2 + (n−2)×D3 + ... + Dn + n (mod 65521)

Adler-32(D) = B * 65536 + A
```
### Esempio:
| Character | ASCII Code | A | B |
| ------ | ------ | ------ | ------ |
| W | 87 | A1 = 1 + 87 = 88 | B1 = A1 = 88|
| i | 105 | A2 = A1 + 105 = 193 | B2 = B1 + A2 = 281 | 
| k | 107 | A3 = A2 + 107 = 300 | B3 = B2 + A3 = 581 |
| i | 105 | A4 = A3 + 105 = 405 | B4 = B3 + A4 = 986 | 
| p | 112 | A5 = A4 + 112 = 517 | B5 = B4 + A5 = 1503 |
| e | 101 | A6 = A5 + 101 = 618 | B6 = B5 + A6 = 2121 |
| d | 100 | A7 = A6 + 100 = 718 | B7 = B6 + A7 = 2839 |
| i | 105 | A8 = A7 + 105 = 823 | B8 = B7 + A8 = 3662 |
| a | 97 | A9 = A8 + 97 = 920 | B9 = B8 + A9 = 4582 |
```
A =  920 =  0x398  (base 16)
B = 4582 = 0x11E6
Output = 0x11E6 << 16 + 0x398 = 0x11E60398
```

# Il programma
## Nota
N.B. : è possibile utilizzare correttamente il programma unicamente su simulatore Mars a causa dell'utilizzo della Syscall 34 per la stampa di un intero in formato esadecimale. Per l'esecuzione su altri simulatori che non supportano la syscall in questione è possibile sostituire il codice chiamata con quello per la stampa di un numero decimale (1) e in seguito convertirlo.
## Funzionamento 
All'avvio il programma richiede una stringa composta da caratteri in codifica ASCII (non estesa). La stringa deve essere inserita mediante la console I/O e deve essere terminata con Invio, fatta eccezione nel caso si raggiunga la capacità massima della memoria a disposizione. In tal caso la stringa verrà troncata automaticamente.<br/>
 La lunghezza massima della stringa è fissata ad un milione di caratteri (compreso il carattere di terminazione).<br/>
Caricata in memoria la stringa, ne viene letto un carattere per volta tramite un loop. Il valore di ogni carattere viene quindi utilizzato secondo l'algoritmo, sommandolo ad A e sommando la A trovata a B.<br/>
 Ad ogni iterazione del loop viene controllato che il carattere letto non sia un carattere di fine stringa, ovvero *null* oppure */n*. In seguito vengono aggiornate le somme di A e B, controllando che il valore di B non possa superare il valore massimo binario a 32 bit per non incorrere in problemi di riporto. Nel caso in cui questo potesse accadere, viene calcolato il modulo della divisione tra il B precedente e il numero primo a 16 bit maggiore possibile, ovvero *65521*, e viene aggiornato B con il resto trovato per ridurne la dimensione. Si procede poi a svolgere la somma di B normalmente. La somma di A, incrementando molto meno rapidamente, non potrà mai incorrere in tali problemi.<br/>
Il programma si arresta a stringa finita stampando il valore esadecimale ottenuto dall'algoritmo.





# Siti Utili
Per controllare i risultati e generare le stringhe di test sono comodi i seguenti siti:

[Generatore stringhe](https://www.browserling.com/tools/random-string)

[Verifica lunghezza stringhe](https://www.charactercountonline.com/)

[Calcolo Adler32](https://md5calc.com/hash)
