Prodotto da:
Villa Fabio 829583

Commenti del programma svolto:

1) is_regexp(RE):

      considera il caso base in cui l'espressione regolare è un atomo,
      considera il caso base in cui l'espressione regolare è epsilon,
      considera i casi ricorsivi:
      
      -sequenza
      -chiusura di kleene (star) 
      -plus 
      -or

      controlla l'arietà di seq e or che sia maggiore o uguale a 2,
      poiché plus e star viene viene passa direttamete a RE al caso base.


2) nfa_comp_reconize(FA_Id, RE):

      viene definito un caso base di arietà 2 e grazie a gensym crea gli stati
      iniziale e finale di tutti gli automi.
      Successivamente vengono gestiti tutti i predicati di arietà 4 che hanno
      il compito di costruire gli automi usando l'algoritmo di thompson:

      -un solo carattere
      -Or tra espressioni regolari
      -star
      -plus
      -sequenza


3) nfa_test(FA_Id, Input):

      accetta in entrata dei valori in input da un array, la prima funzione
      di arietà 2 fa il primo passo, valutando il caso che sia una espsilon
      o un valore accettabile, successivamente viene mandata ad altre
      espressioni di arietà 3 che prendo lo stato e avanzadno, sempre tenendo
      conto di epsilon, fino ad arrivare allo stato finale.


4) nfa_list:

      restituisce la lista degli stati degli automi se viene chiamata con 
      arietà 0, se invece viene chiamata con il nome dell'automa restituisce
      gli stati inziali, finali e i delta. 


5) nfa_clear:

      cancella gli automi se viene chiamata con arietà 0, 
      se invece viene chiamata con il nome dell'automa elimina gli stati.


ATTENZIONE:

      Se la base di dati è vuota (nessun nfa creato) 
      non chiamare nfa_list senza aver creato prima un auto altrimenti 
      torna errore se la base di dati è vuota
