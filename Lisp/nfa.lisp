;;;;Fabio Villa 829583

;; T if RE is a regular expression nil otherwise.
(defun is-regexp (RE)
  (cond ((and (listp RE)
              (or (eql (car RE) 'seq) (equal (car RE) 'or)))
           (and (>= (length (cdr RE)) 2) (mapcar 'is-regexp (cdr RE))))
         ((and (listp RE) (or (eql (car RE) 'plus) (equal (car RE) 'star)))
          (and (= (length (cdr RE)) 1) (mapcar 'is-regexp (cdr RE))))
         (T T)))

;; Ritorna un T se è una lista di simboli dell'alfabeto
(defun simbol-list (l)
  (and (atom (car l))
       (not (or (eql (second l) 'seq) (eql (second l) 'or)
            (eql (second l) 'star) (eql (second l) 'plus)))
       (atom (third l))))

;; Caso base: costruisce l'automa  ottenuto dalla RE
;; Se is-regexp T costruisce l'automa se no ritona nil
(defun nfa-regexp-comp (RE)
  (if (is-regexp RE)
    (let ((initial (gensym "q"))
          (final (gensym "q")))
      (nfa-smistamento (list initial final) RE))
  nil))

;;Ritona l'automa e chiama le varie funzioni per la costruzione dell'nfa
(defun nfa-smistamento (listq RE)
  (cond ((atom RE) (nfa-regexp-comp-sc listq RE))
        ((equal (car RE) 'seq) (nfa-regexp-comp-seq listq (cdr RE)))
        ((equal (car RE) 'or) (nfa-regexp-comp-or listq (cdr RE)))
        ((equal (car RE) 'plus) (nfa-regexp-comp-plus listq (cdr RE)))
        ((equal (car RE) 'star) (nfa-regexp-comp-star listq (cdr RE)))
        ((atom (car RE)) (nfa-regexp-comp-sc listq RE))
        (T (nfa-regexp-comp-sc listq RE))))

;;Ritorna l'automa costruito per riconoscere la seq
;;usando l'algoritmo di Thompson
(defun nfa-regexp-comp-seq (listq RE)
 (if (null (cdr RE))
      (nfa-regexp-comp (car RE))
    (let ((nfa-half (nfa-regexp-comp (car RE)))
          (nfa-final (nfa-regexp-comp-seq listq (cdr RE))))
      (append (list (car nfa-half))
	      (list (second nfa-final))
	      (cdr (cdr nfa-half))
	      (list (list (second nfa-half) 'epsilon (car nfa-final)))
	      (cdr (cdr nfa-final))))))

;;Restituisce l'automa costruito per riconoscere la or
;;usando l'algoritmo di Thompson
(defun nfa-regexp-comp-or (listq RE)
 (if (null (cdr RE))
     (nfa-regexp-comp (car RE))
   (let ((nfa-half (nfa-regexp-comp (car RE)))
         (nfa-final (nfa-regexp-comp-or listq (cdr RE)))
	 (n1-state (gensym "q"))
	 (n2-state (gensym "q")))
     (append (list n1-state)
	     (list n2-state)
             (list (list n1-state 'epsilon (car nfa-half)))
             (list (list n1-state 'epsilon (car nfa-final)))
             (cdr (cdr nfa-half)) (cdr (cdr nfa-final))
             (list (list (second nfa-half) 'epsilon n2-state))
             (list (list (second nfa-final) 'epsilon n2-state))))))

;;Restituisce l'automa costruito per riconoscere la plus
;;usando l'algoritmo di Thompson
(defun nfa-regexp-comp-plus (listq RE)
  (let ((nfa-plus (nfa-regexp-comp (car RE))))
    (append listq
            (list (list (car listq) 'epsilon (car nfa-plus)))
            (cdr (cdr nfa-plus))
            (list (list (second nfa-plus) 'epsilon (second listq)))
            (list (list (second nfa-plus) 'epsilon (car nfa-plus))))))


;;Restituisce l'automa costruito per riconoscere la star
;;usando l'algoritmo di Thompson
(defun nfa-regexp-comp-star (listq RE)
  (let ((nfa-star (nfa-regexp-comp-plus listq RE)))
    (append nfa-star (list (list (car listq) 'epsilon (second nfa-star))))))

;;Restituisce l'automa costruito per riconoscere il singolo carattere
;;viene usato anche come caso base
(defun nfa-regexp-comp-sc (listq RE)
  (append listq (list (list (car listq) RE (second listq)))))

;;Ritona T se l'input viene completamete esauito, ritorna un errore
;;se FA non ha una corretta struttura dell'automa
(defun nfa-test (FA Input)
  (cond ((and (not (null Input))
	      (atom Input))
	 nil)
	((and (not (atom Input))
              (or (eql (car Input) 'seq)
                  (eql (car Input) 'or)
                  (eql (car Input) 'star)
                  (eql (car Input) 'plus)) nil))
        ((not (is-nfa FA))
         (format *standard-output*
                  "Error: ~S is not a Finite State Automa. ~%"
                  FA))
        (T (nfa-accept FA Input (car FA)))))

;;Ritorna T se ha una struttura di un nfa
(defun is-nfa (FA)
  (if (atom FA) nil
    (and (>= (length FA) 3)
         (atom (car FA))
         (atom (second FA))
         (deltas (rest (rest FA))))))

;;Ritorna T se checkdelta è una delta
(defun delta (checkdelta)
  (if (atom checkdelta) nil
    (and (= (length checkdelta) 3)
         (atom (car checkdelta))
         (not (or (eql (second checkdelta) 'seq)
                  (eql (second checkdelta) 'or)
                  (eql (second checkdelta) 'star)
                  (eql (second checkdelta) 'plus)))
         (atom (third checkdelta)))))

;;Ritorna T se l è una lista di delta
(defun deltas (l)
  (if (= (length l) 1)
      (delta (car l))
    (and (delta (car l))
         (deltas (cdr l)))))

;;Ritorna T se Input vine esaurito del tutto e l'automa di trova
;;nello stato finale
(defun nfa-accept (FA Input state)
  (let ((next-delta-state (car (find-delta-current-state (cdr (cdr FA))
                                                    (car Input)
                                                    state)))
	(next-epsilon (find-delta-current-state (cdr (cdr FA))
                                            'epsilon
                                            state)))
    (cond  ((not (null next-epsilon))
            (let ((transition
                  (nfa-accept FA Input (car next-epsilon))))
              (if (not (null transition))
                transition
                (nfa-accept FA Input (second next-epsilon)))))
           ((null Input) (eql state (second FA)))
           ((eql (car Input) 'epsilon) (nfa-accept FA (cdr Input) state))
           ((null next-delta-state) nil)
           (T (nfa-accept FA (cdr Input) next-delta-state)))))

;;Ritorna la lista di tutti i possibili risultati di tutte le delta
(defun find-delta-current-state (deltalist firstInput state)
  (let ((first-delta (car deltalist)))
    (cond ((null deltalist)
	   nil)
	  ((and (eql (car first-delta) state)
                (equal firstInput (second first-delta)))
           (append (list (third first-delta))
                   (find-delta-current-state (cdr deltalist)
                                            firstInput
                                            state)))
          (T (find-delta-current-state (cdr deltalist)
                                       firstInput
                                       state)))))
        
;;;; eof nfa.lisp
