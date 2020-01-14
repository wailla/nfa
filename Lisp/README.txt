Prodotto da:
Villa Fabio 829583

Commenti del programma svolto:

(is-regexp RE):

	considera un caso base dove RE sia atomico,
	l'espressione regolare è un atomo, considera 
	il caso base in cui l'espressione regolare è epsilon,
      	considera i casi ricorsivi, andando a valutare tutta la lista:
	sequenza, chiusura di kleene (star), plus, or.
        Viene controllato l'arieta di ogni singolo funtore riservato.
        Ritorna T se è un'espressione regolare


(nfa-regexp-comp RE):

	ritorna T se viene creato l'automa ottenuto dalla RE se è una espressione 
        regolare, altrimenti nil.
        Se RE non è un'espressione regolare ritorna nil.


(nfa-test FA Input):

        ritorna T se dato un Input l'automa si trova nello stato finale.
        Se FA è non è un automa ritorna un errore.