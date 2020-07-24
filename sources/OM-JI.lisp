;; Functions by Charles K. Neimog (2019 - 2020) | Universidade Federal de Juiz de Fora | charlesneimog.com

(in-package :om)

;; ======================================== Functions ===================================

(defun list-of-listp (thing) (and (listp thing) (every #'listp thing)))
(deftype list-of-lists () '(satisfies list-of-listp))

;; thanks for Reddit user DREWC for code of list-of-listp and list-of-lists

;; ======================================== Just-Intonation ==============================

(defmethod! rt->mc ((ratio list) (fundamental list))
:initvals ' ((1/1 11/8 7/4) (6000))
:indoc ' ("convert list of ratios for midicent in Just Intonation" "this is the fundamental of the Just Intonation") 
:icon 002
:doc "convert ratio for note in Just Intonation"

(if (let ((foo ratio)) (typep foo 'list-of-lists))

(loop :for cknloop :in ratio :collect (loop :for n :in cknloop :collect (f->mc (om* (mc->f fundamental) n))))
(loop :for n :in ratio :collect (f->mc (om* (mc->f fundamental) n)))))

(defmethod! ratio->mc ((ratio list) (fundamental number))
:initvals ' ((1/1 11/8 7/4) 6000)
:indoc ' ("convert list of ratios for midicent in Just Intonation" "this is the fundamental of the Just Intonation") 
:icon 002
:doc "convert ratio for note in Just Intonation"

(if (let ((foo ratio)) (typep foo 'list-of-lists))

(loop :for cknloop :in ratio :collect (loop :for n :in cknloop :collect (f->mc (om* (mc->f fundamental) n))))
(loop :for n :in ratio :collect (f->mc (om* (mc->f fundamental) n)))))

;; =================

(defmethod! ratio->mc ((ratio number) (fundamental number))
:initvals ' (11/8 6000)
:indoc ' ("convert a list of ratios for midicent in Just Intonation" "this is the fundamental of the Just Intonation") 
:icon 002
:doc "convert ratio for note in Just Intonation"

(f->mc (om* (mc->f fundamental) ratio)))

;; ===================================================

(defmethod! octave-reduce ((note list) (grave number))
:initvals ' ((4800 7200 6000) 6000)
:indoc ' ("list of midicents" "nota mais grave" "octave")
:icon 002
:doc "Reduzir lista de Midicents para uma determinado espaco determinado por uma nota grave e uma quantidade de oitavas"


(let* ((range (* 1 1200)))

(if (let ((foo note)) (typep foo 'list-of-lists))
   
      (loop :for listadelista :in note :collect (mapcar #' (lambda (x) (+ (mod x range) grave)) listadelista))
      (mapcar #' (lambda (x) (+ (mod x range) grave)) note))))


;; ===================================================

(defmethod! range-reduce ((notelist list) (grave number) (aguda number))
:initvals ' ((4800 7200 6000) 6000 7902)
:indoc ' ("list of midicents" "nota mais grave" "octave" "mode => list or list-of-lists?")
:icon 002
:doc "Reduzir lista de Midicents para uma determinado espaço determinado por uma nota grave e uma quantidade de oitavas"

(if (om>= (- aguda grave) 1200)
(if (let ((foo notelist)) (typep foo 'list-of-lists))

(loop :for notelistloop :in notelist :collect
      (mapcar (lambda (x)
	  (loop :for new-val := x
		  :then (if (< new-val aguda)
			    (+ new-val 1200)
			    (- new-val 1200))
		:until (and (<= grave new-val)
			    (>= aguda new-val))
		:finally (return new-val)))
	notelistloop))

(mapcar (lambda (x)
	  (loop :for new-val := x
		  :then (if (< new-val aguda)
			    (+ new-val 1200)
			    (- new-val 1200))
		:until (and (<= grave new-val)
			    (>= aguda new-val))
		:finally (return new-val)))
	notelist)) (print "RANGE-REDUCE: The diference between the inlet2 e inlet3 must be at least 1200 cents")))

;; ===================================================

(defmethod! filter-ac-inst ((notelist list) (approx integer) (temperament integer))
:initvals ' ((6000 6530 7203 5049) 10 2)
:indoc ' ("list of notes (THIS OBJECT DON'T READ LISTS OF LIST" "Cents aproximation of the 12-DEO" "aproximacao de escala temperada 1/2 1/4 1/8 de tom") 
:icon 002
:doc "Filter of notes that can be played by an acoustic instrument."

(let* ((filter 
(loop :for cknloop :in notelist :collect 

      (if (om= (om+ 
          (first (list (if (om< (om- cknloop (approx-m cknloop temperament)) approx) 1 0)
                       (if (om> (om- cknloop (approx-m cknloop temperament)) (om- approx (om* approx 2))) 1 0))) 

              (second (list 
                       (if (om<  (om- cknloop (approx-m cknloop temperament)) approx) 1 0) 

                       (if (om> (om- cknloop (approx-m cknloop temperament)) (om- approx (om* approx 2))) 1 0)))) 2) cknloop 0))))


(list-filter #'(lambda (x) (om= x 0)) filter 'reject)))

;; ===================================================

(defmethod! modulation-notes ((listnote list) (listnote2 list) (cents integer))
:initvals ' ((6000 6530) (7203 5049) 2)
:indoc ' ("first notelist of the comparation" "second notelist of the comparation" "aproximação de escala temperada 1/2 1/4 1/8 de tom" "temperament! 2 for 2-DEO 4 for 24-DEO") 
:icon 002
:doc "Filter of notes that can be played by an acoustic instrument."

(let* ((result (loop :for cknloop1 :in listnote :collect (loop :for cknloop2 :in listnote2 :collect 
      (if (om= (+ 
          (if (< (om- (om- cknloop1 cknloop2) (approx-m (om- cknloop1 cknloop2) 2)) cents) 1 0) 
          (if (> (om- (om- cknloop1 cknloop2) (approx-m (om- cknloop1 cknloop2) 2)) (om- cents (* cents 2))) 1 0)) 2) (list cknloop1 cknloop2) 0)))) 

(result2 (remove 0 (flat result 1)))

(result3 (loop :for note :in result2 :collect 
        (if (and (om< (om- 
                       (first (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note)) 
                       (second (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note))) cents)
                 (om< (om- cents (om* cents 2)) 
                      (om- (first (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note)) 
                      (second (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note))))) note 0)))) (remove 0 result3)))

;; ===================================================

(defmethod! modulation-notes-fund ((listnote list) (listnote2 list) (cents integer) (temperamento integer))
:initvals ' ((6000 6530) (7203 5049) 10 4)
:indoc ' ("first notelist of the comparation" "second notelist of the comparation" "aproximação de escala temperada 1/2 1/4 1/8 de tom" "temperament! 2 for 2-DEO 4 for 24-DEO") 
:icon 002
:doc "Filter of notes that can be played by an acoustic instrument."

(let* ((result (loop :for cknloop1 :in listnote :collect 

                     (loop for cknloop2 in listnote2 collect (if (om= (+ 
                                                          (if (< (om- (om- cknloop1 cknloop2) 
                                                                 (approx-m (om- cknloop1 cknloop2) temperamento)) cents) 1 0) 
                                                          (if (> (om- (om- cknloop1 cknloop2) 
                                                                 (approx-m (om- cknloop1 cknloop2) temperamento)) (om- cents (* cents 2))) 1 0)) 2) 
                                                                                                  (list cknloop1 cknloop2) 0))))
(result2 (remove 0 (flat result 1))))

  (loop :for cknloop3 :in result2 :do (print  (let*  
                                               ((result3-2 (om- (first cknloop3) (second cknloop3))))

  (if 
      (or (om= result3-2 0) (om= result3-2 1200) (and (om> 10 result3-2) (om< -10 result3-2))) (x-append cknloop3 "are equal")
      (x-append cknloop3 "will be equal if the second list have has the fundamental with the difference of" (approx-m result3-2 temperamento) 'cents))))) 'end))

;; ===================================================

(defmethod! choose ((notelist list) (chord-n integer))
:initvals ' (((6000 6530) (7203 5049)) (2))
:indoc ' ("list of notes (THIS OBJECT DON'T READ LISTS OF LIST" "Cents aproximation of the 12-DEO" "aproximação de escala temperada 1/2 1/4 1/8 de tom" "number of the chord") 
:icon 002
:doc "Filter of notes that can be played by an acoustic instrument."

(nth (om- chord-n 1) notelist))


(defmethod! choose ((notelist list) (chord-n list))
:initvals ' (((6000 6530) (7203 5049)) (2 3 2))
:indoc ' ("list of notes (THIS OBJECT DON'T READ LISTS OF LIST" "Cents aproximation of the 12-DEO" "aproximação de escala temperada 1/2 1/4 1/8 de tom" "number of the chord") 
:icon 002
:doc "Filter of notes that can be played by an acoustic instrument."

(loop :for cknloop :in chord-n :collect (nth (om- cknloop 1) notelist)))

;; ===================================================

(defmethod! rt-octave ((fraq list) &optional (octave))
:initvals ' ((1/3 1 5/3) 2)
:indoc ' ("list of ratios" "2 for one octave; 4 for 2 octaves; 8 for 3; etc...") 
:icon 002
:doc "This object reduce ratios for one octave between 1/1 and 2/1."

(rt-octave-fun fraq octave))


(defmethod! rt-octave ((fraq ratio) &optional (octave))
:initvals ' (3/2 2)
:indoc ' ("list of ratios" "2 for one octave; 4 for 2 octaves; 8 for 3; etc...") 
:icon 002
:doc "This object reduce ratios for one octave between 1/1 and 2/1."

(/ fraq (expt octave (floor (log fraq octave)))))

; ====== Function 

(defun rt-octave-fun (fraq octave)

(if (let ((foo fraq)) (typep foo 'list-of-lists))

(loop :for cknloop :in fraq :collect (loop :for cknloop2 :in cknloop :collect (/ cknloop2 (expt octave (floor (log cknloop2 octave))))))

(loop :for cknloop2 :in fraq :collect (/ cknloop2 (expt octave (floor (log cknloop2 octave)))))))


;; =================================== Harry Partch ==========================================
(defmethod! Diamond ((limite integer))
:initvals ' (11)      
:indoc ' ("limit-n for the diamond")
:outdoc ' ("utonality" "otonality")
:numouts 2 
:icon 003
:doc "Create a Tonality-Diamond according to Harry Partch's Theory. See the GENESIS OF MUSIC of Harry Partch. 
In the outlet of the left, result are utonality. Outlet of the right are otonality."

(values 
(loop :for x :in (arithm-ser 1 limite 2) :collect (loop :for y :in (arithm-ser 1 limite 2) :collect (/ x y))) 
(loop :for x :in (arithm-ser 1 limite 2) :collect (loop :for y :in (arithm-ser 1 limite 2) :collect (/ y x)))))

;; ===================================================

(defmethod! Diamond-Identity ((identity list))
:initvals ' ((11 19 97))       
:indoc ' ("limit-n for the diamond")
:outdoc ' ("utonality" "otonality")
:numouts 2
:icon 003
:doc "Create a Tonality-Diamond with a list of Identities. See the GENESIS OF MUSIC of Harry Partch. 
In the outlet of the left, result are utonality. Outlet of the right are otonality."

(values 
(loop :for x :in identity :collect (loop :for y :in identity :collect (/ x y))) 
(loop :for x :in identity :collect (loop :for y :in identity :collect (/ y x)))))

;; ===================================================
-
(defmethod! otonal-inverse ((otonal list))
:initvals ' ((1/1 3/2 5/4))       
:indoc ' ("otonal chord")
:icon 003
:doc "Give the utonal chord of a otonal chord. Inverse of the otonal chord"


(let* (

(task1 (loop :for y :in otonal :collect (denominator y)))
(task2 (loop :for y :in otonal :collect (numerator y)))
(task3 (om/ task1 task2)))
(rt-octave-fun task3))

)

;; ===================================================
-
(defmethod! utonal-inverse ((utonal list))
:initvals ' ((1/1 4/3 6/5))       
:indoc ' ("utonal chord")
:icon 003
:doc "Give the otonal chord of a utonal chord. Inverse of the utonal chord"


(let* (

(task1 (loop :for y :in utonal :collect (numerator y)))
(task2 (loop :for y :in utonal :collect (denominator y)))
(task3 (om/ task1 task2)))
(rt-octave-fun task3))

)


;; ;; =================================== Ben Johnston ======================================

(defmethod! interval-sob ((fund number)(ratio number) (sieve list))
:initvals ' (6000 11/8 (2 3 7 11 12))     
:indoc ' ("fundamental note of sobreposition" "Just Intonation interval" "list of sopreposition (I recomend the use o 'crible' object")
:icon 001
:doc "create a sobreposition intervalar of Just Intonation"

(let* ((interval (om- (f->mc (om* (mc->f fund) ratio))fund)))
(loop :for n :in sieve :collect (+ fund (* interval n)))))

;; ===================================================


(defmethod! arith-mean ((grave number) (agudo number))
:initvals ' (1/1 2/1)
:indoc ' ("first ratio" "second ratio")
:icon 001
:doc "It gives the arithmetic mean of two ratio. 

This is a procedure used by Ben Johnston in your strings quartets no. 2 and no. 3. See the article Scalar Order as a Compositional Resource (1964)"

(/ (+ grave agudo) 2))

;; ===================================================

(defmethod! arith-mean-sob ((grave number) (agudo number))
:initvals ' (1/1 5/4)
:indoc ' ("first ratio" "second ratio")
:icon 001
:doc "It gives the arithmetic mean of two ratio. 

This is a procedure used by Ben Johnston in your strings quartets no. 2 and no. 3. See the article Scalar Order as a Compositional Resource (1964)"

(x-append grave (/ agudo (/ (+ grave agudo) 2)) (* grave (/ (+ grave agudo) 2)) agudo))

;; ===================================================

(defmethod! johnston-sob ((ratio number) (sobreposition number) (fundamental number))
:initvals ' (3/2 3 7200)
:indoc ' ("first ratio" "sobreposition number" "fundamental")
:icon 001
:doc "ainda a fazer"


(let* (
(utonal-sobr (/ (denominator ratio) (numerator ratio)))
(sobr (arithm-ser 1 sobreposition 1))
(otonal (loop :for n :in (om^ ratio sobr) collect (f->mc (om* (mc->f fundamental) n))))
(utonal (loop :for n :in (om^ utonal-sobr sobr) collect (f->mc (om* (mc->f fundamental) n)))))
(x-append utonal fundamental otonal)))


;; =================================== Erv Wilson =========================================

(defmethod! MOS ((ratio number)(fund number) (aguda number) (sobreposition number))
:initvals ' (4/3 6000 7200 11)     
:indoc ' ("fundamental note of sobreposition" "Just Intonation interval" "high note" "number of sobreposition")
:icon 005
:doc "This object creates a Moment of Symmetry without a octave equivalence. For make the octave equivalence use the object Octave-reduce, choose the range of the this MOS. 

MOS is a Theory of the composer Erv Wilson.                  

Wilson coined the term (MOS) to describe those scales resulting from a chain of intervals that produce two (and not three) different-sized intervals. 

These intervals are designated as the small (s) and large (L) intervals (FOR MAKE THIS USE THE OBJECT MOS-type). 

The relative number of s and L intervals in an MOS is co-prime, i.e., they share no common factors other than 1. Fractions are used to represent MOS scales: the numerator shows the size of the generator, and the denominator shows the number of notes in the scale. 

The numerator and denominator of fractions representing MOS are also co-prime. Wilson organizes these fractions hierarchically on the Scale Tree. MOS are not only scales in their own right but also provide a framework or template for constructing a family of Secondary MOS scales. (in NARUSHIMA - Microtonality and the Tuning Systems of Erv Wilson-Routledge)"

(let*  

    ((interval (om- (f->mc (om* (mc->f fund) ratio)) fund))

    (mos-create (loop for n in (arithm-ser 1 sobreposition 1) collect (+ fund (* interval n)))))

(x-append fund (mapcar (lambda (x)
	  (loop :for new-val := x
		  :then (if (< new-val aguda)
			    (+ new-val 1200)
			    (- new-val 1200))
		:until (and (<= fund new-val)
			    (>= aguda new-val))
		:finally (return new-val)))
	mos-create) aguda)))


;; ===================================================

(defmethod! MOS-verify ((notelist list))
:initvals ' ((6754 6308 7062 6616 6178))    
:indoc ' ("list of notes - object-MOS")
:icon 005
:doc "This object do the verification whether a list of notes is a MOS or not. If yes, informs the internal symmetry of your intervals, s for small intervals and L for Large interval. See Microtonality and the Tuning Systems of Erv Wilson-Routledge of NARUSHIMA"


(let* 
    ((action1 (loop :for cknloop :in (x->dx (sort-list (flat notelist)))

        :collect (if (om= cknloop (first (sort-list (remove-dup (x->dx (sort-list (flat notelist))) 'eq 1)))) "s" "L"))))

(if (om= (length (remove-dup (x->dx (sort-list (flat notelist))) 'eq 1)) 2) action1 "This is not a MOS")))

;; ===================================================

(defmethod! MOS-check ((interval number)(fund number) (aguda number) (sobreposition number) (number_of_interval number))
:initvals ' (4/3 6000 7200 11 2)     
:indoc ' ("fundamental note of sobreposition" "Just Intonation interval" "high note" "number of sobreposition" "interval number of the MOS")
:icon 005
:doc "This object creates a Moment of Symmetry without a octave equivalence. For make the octave equivalence use the object Octave-reduce, choose the range of the this MOS. 

MOS is a Theory of the composer Erv Wilson.                  

Wilson coined the term (MOS) to describe those scales resulting from a chain of intervals that produce two (and not three) different-sized intervals. 

These intervals are designated as the small (s) and large (L) intervals (FOR MAKE THIS USE THE OBJECT MOS-verification). 

The relative number of s and L intervals in an MOS is co-prime, i.e., they share no common factors other than 1. Fractions are used to represent MOS scales: the numerator shows the size of the generator, and the denominator shows the number of notes in the scale. 

The numerator and denominator of fractions representing MOS are also co-prime. Wilson organizes these fractions hierarchically on the Scale Tree. MOS are not only scales in their own right but also provide a framework or template for constructing a family of Secondary MOS scales. (in NARUSHIMA - Microtonality and the Tuning Systems of Erv Wilson-Routledge)"


(let* ((action1 (loop :for x :in (arithm-ser 1 sobreposition 1) :collect 
                      (if (om= (length (remove-dup (x->dx (x-append fund (sort-list
               
                                                                          (mapcar #' (lambda (x) (+ (mod x (- aguda fund)) fund)) 
                                                                          (loop :for n :in (arithm-ser 1 x 1) :collect 

               (+ fund (* (om- (f->mc (om* (mc->f fund) interval)) fund) n))))) aguda)) 'eq 1)) number_of_interval) x 0))))

(remove 0 action1)))

;; ===================================================

(defmethod! Cps-Hexany ((list list))
:initvals ' ((5 7 13 17))    
:indoc ' ("list of just four harmonics")
:icon 006
:doc "This object create a Hexany of the theory of Combination Product-Set of the Composer Erv Wilson."

(if (= 4 (length list)) 

(let* 

((combinations (cond
   ((<=  2 0) list)
   (t (flat-once 
       (cartesian-op list (combx list (1- 2)) 'x-append)))))


  (hexany (loop :for cknloop :in combinations :collect 

        (let* ((ordem (sort-list cknloop))
               (iguais (let ((L()))
                         (loop :for x :from 0 :to (1- (length ordem)) :do
                               (when (not (equal (nth (+ x 1) ordem) (nth x ordem)))
                                 (push (nth x ordem) L)))
                         (reverse L))))
          (if (om= (length iguais) 2) iguais nil))))
  (cknremove (remove nil hexany)))

(remove-duplicates cknremove :test #'equal))
(print "This is not a Hexany, The CPS Hexany needs 4 numbers: for example 3 7 13 17")))


;; ===================================================
(defmethod! hexany-connections ((harmonico list) (hexany list))
:initvals ' ((3 13) ((3 5) (3 13) (5 13) (3 21) (5 21) (13 21)))    
:indoc ' ("list of two harmonics" "list of just four harmonics")
:icon 006
:doc "This object shown the Hexany connections of the theory of Combination Product-Set of the Composer Erv Wilson."

(let*
  ((action1 (loop :for cknloop :in hexany
   collect (let*  ((result1 (first harmonico)) (result2 (first cknloop)) (result3 (second harmonico)) (result4 (second cknloop)))
       
             (remove nil 
                     (remove-duplicates (list
                             (if (or  (om= result1 result2) (om= result1 result3)) cknloop nil) 
                             (if (or (om= result3 result2) (om= result3 result4)) cknloop nil)) :test #'equal))))))
        


  (flat (remove nil action1) 1)))

;; ===================================================
(defmethod! eikosany-connections ((vertice list) (eikosany list))
:initvals ' ((1 3 9) ((1 3 5) (1 3 7) (1 5 7) (3 5 7) (1 3 9) (1 5 9) (3 5 9) (1 7 9) (3 7 9) (5 7 9) (1 3 11) (1 5 11) (3 5 11) (1 7 11) (3 7 11) (5 7 11) (1 9 11) (3 9 11) (5 9 11) (7 9 11)))    
:indoc ' ("list of tree harmonics" "list of the cps-eikosany")
:icon 006
:doc "This object shown the Eikosany connections of the theory of Combination Product-Set of the Composer Erv Wilson."

(defun same-elem-p (lst1 lst2)
  (cond ((not (null lst1))
         (cond ((member (car lst1) lst2)
                (same-elem-p (cdr lst1) lst2))
               (t nil)))
        (t t)))

(let* ((task1 (loop for cknloop in eikosany collect (if
          
      (om<= 2 (reduce #'+ 
                      (x-append
              (if (same-elem-p (list (first vertice)) cknloop) 1 nil)
              (if (same-elem-p (list (second vertice)) cknloop) 1 nil)
              (if (same-elem-p (list (third vertice)) cknloop) 1 nil))))
           cknloop nil))))
(remove nil task1)))


;; ===================================================

(defmethod! Hexany-triads ((harmonicos list))
:initvals ' (1 3 5 7)      
:indoc ' ("harmonicos")
:outdoc ' ("sub-harmonic" "harmonic")
:numouts 2 
:icon 006
:doc ""

(values 

(let* ((actionmain (loop for cknloopmain in (arithm-ser 1 (length harmonicos) 1) collect
      (let* 
((combinations (cond
   ((<=  2 0) (remove (choose harmonicos cknloopmain) harmonicos))
   (t (flat-once 
       (cartesian-op (remove (choose harmonicos cknloopmain) harmonicos) (combx (remove (choose harmonicos cknloopmain) harmonicos) (1- 2)) 'x-append)))))


  (action1 (loop for cknloop in combinations collect 

        (let* ((ordem (sort-list cknloop))
               (iguais (let ((L()))
                         (loop for x from 0 to (1- (length ordem)) do
                               (when (not (equal (nth (+ x 1) ordem) (nth x ordem)))
                                 (push (nth x ordem) L)))
                         (reverse L)))
          (final (if (om= (length iguais) 2) iguais nil))) (remove nil final)))))


(remove-duplicates (remove nil action1) :test #'equal))))

(actionmain2 (loop for ckn-loop in actionmain collect (loop for ckn-loop2 in ckn-loop collect (reduce #'* ckn-loop2)))))

(loop for cknloop2 in actionmain2 collect (loop for cknloop3 in cknloop2 collect (/ cknloop3 (expt 2 (floor (log cknloop3 2)))))))



; ====

(let* ((ratios (loop for cknloop4 in (arithm-ser 1 (length harmonicos) 1) collect 
       (let* ((choose (nth (om- cknloop4 1) harmonicos)))
         (om* choose (remove choose harmonicos))))))

(loop for cknloop2 in ratios collect (loop for cknloop3 in cknloop2 collect (/ cknloop3 (expt 2 (floor (log cknloop3 2)))))))))
     

;; ===================================================

(defmethod! CPS-connections ((lista list) (ratio number) (stacking number))
:initvals ' ((209/128 1843/1024 133/128 1067/1024 77/64 679/512) 3 4)    
:indoc ' ("list of ratio of a Hexany, Eikosany or others Wilson's CPS" "choose a ratio for the list in inlet1" "3 for triads; 4 for tetrads; etc")
:icon 006
:doc "This object show the connections of a CPS of Erv Wilson in a list of ratios and a number of stacking - example: Triads, Tetrads etcs..."


(let* 
    ((choose (nth (om- ratio 1) lista))

     (loop1 (loop for it-11 in lista collect 
       (x-append (if (om= (numerator choose) (numerator it-11)) it-11 nil)
       (if (om= (denominator choose) (denominator it-11)) it-11 nil))))

     (action1 (remove-dup (remove nil (flat loop1)) 'eq 1))

     (combinations (let* ((stacking (1- stacking))) (combx action1 stacking)))



(action2 (loop for cknloop in combinations collect (if  (om= (length 
                                                     (let ((L())) 
      (loop for x from 0 to (1- (length (sort-list cknloop))) do
          (when (not (equal (nth (+ x 1) (sort-list cknloop)) (nth x (sort-list cknloop))))
            (push (nth x (sort-list cknloop)) L))) 
      (reverse L))) stacking) (let ((L())) (loop for x from 0 to (1- (length (sort-list cknloop))) do
          (when (not (equal (nth (+ x 1) (sort-list cknloop)) (nth x (sort-list cknloop))))
            (push (nth x (sort-list cknloop)) L))) (reverse L)) nil)))

(action3 (remove nil action2)))

(remove-duplicates action3 :test #'equal)))

;; ===================================================

(defmethod! cps-eikosany ((6-notes list))
:initvals ' ((1 3 5 7 9 11))      
:indoc ' ("six harmonic notes | if you don't put 6 notes the result will not be an eikosany.")
:outdoc ' ("harmonic")
:icon 006
:doc ""
(cps-eikosany-fun 6-notes))

; ====== Functions 

(defun cps-eikosany-fun (6-notes)

(let* 

((combinations (cond
   ((<=  3 0) 6-notes)
   (t (flat-once 
       (cartesian-op 6-notes (combx 6-notes (1- 3)) 'x-append)))))


  (hexany (loop for cknloop in combinations collect 

        (let* ((ordem (sort-list cknloop))
               (iguais (let ((L()))
                         (loop for x from 0 to (1- (length ordem)) do
                               (when (not (equal (nth (+ x 1) ordem) (nth x ordem)))
                                 (push (nth x ordem) L)))
                         (reverse L))))
          (if (om= (length iguais) 3) iguais nil))))
  (cknremove (remove nil hexany)))

(remove-duplicates cknremove :test #'equal)))


;; ===================================================

(defmethod! cps ((notes list) (quantidade number))
:initvals ' ((1 3 5 7 9 11) (3))
:indoc ' ("six harmonic notes | if you don't put 6 notes the result will not be an eikosany.")
:outdoc ' ("harmonic")
:icon 006
:doc ""
(cps-fun notes quantidade))

; ====== Functions 

(defun cps-fun (notes quantidade) 

(let* 

((combinations (cond
   ((<=  quantidade 0) notes)
   (t (flat-once 
       (cartesian-op notes (combx notes (1- quantidade)) 'x-append)))))


  (hexany (loop for cknloop in combinations collect 

        (let* ((ordem (sort-list cknloop))
               (iguais (let ((L()))
                         (loop for x from 0 to (1- (length ordem)) do
                               (when (not (equal (nth (+ x 1) ordem) (nth x ordem)))
                                 (push (nth x ordem) L)))
                         (reverse L))))
          (if (om= (length iguais) quantidade) iguais nil))))
  (cknremove (remove nil hexany)))

(remove-duplicates cknremove :test #'equal)))


;; ===================================================

(defmethod! eikosany-triads ((6-notes list))
:initvals ' ((1 3 5 7 9 11))      
:indoc ' ("three harmonic notes | if you don't put 3 notes the result will not be an eikosany triads.")
:outdoc ' ("sub-harmonic" "harmonic")
:numouts 2
:icon 006
:doc ""

(print "This object embedded functions by Mikhail Malt")

(values 

;; subharmonic

(let* ((action1 (cps-fun 6-notes 3))

(action2 (loop for cknloop5 in action1 collect (rt-octave-fun
              (let* ((action2-1 (set-difference 6-notes cknloop5))
                     (action2-2 (cps->ratio-fun (cps-fun cknloop5 2))))
                (loop for cknloop6 in action2-1 collect (om* action2-2 cknloop6)))))))
(flat action2 1))


;;harmonic

(let* ((action1 (cps-fun 6-notes 3))

(action2 (loop for cknloop1 in action1 collect (rt-octave 
          (let* ((action2-1 (cps->ratio-fun (cps-fun (set-difference 6-notes cknloop1) 2))))
            (loop for cknloop1-1 in action2-1 collect (om* cknloop1 cknloop1-1)))))))

(flat action2 1))))

;; ===================================================

(defmethod! eikosany-tetrads ((6-notes list))
:initvals ' ((1 3 5 7 9 11))      
:indoc ' ("three harmonic notes | if you don't put 3 notes the result will not be an eikosany triads.")
:outdoc ' ("sub-harmonic" "harmonic")
:numouts 2
:icon 006
:doc ""

(values 
(let* (
(action1 (cps-fun 6-notes 4)))
(loop for cknloop in action1 collect (cps->ratio-fun (cps-fun cknloop 3))))

;; harmonic

(let* (
(action1 (cps-fun 6-notes 4)))

(loop for cknloop in action1 collect 
      (rt-octave (let*
          ((action2-1 (set-difference 6-notes cknloop))
          (action2-2 (reduce #'* action2-1)))
          (om* cknloop action2-2)))))))



;; ===================================================

(defmethod! cps->ratio ((hexany list))
:initvals ' (1 3 5 7)      
:indoc ' ("harmonicos")
:outdoc ' ("ratio list")
:icon 006
:doc ""

(cps->ratio-fun hexany))

; ====== Functions 

(defun cps->ratio-fun (hexany)
(let* ((action1 
(loop for cknloop in hexany collect (reduce #'* cknloop))))

(loop for cknloop2 in action1 collect (/ cknloop2 (expt 2 (floor (log cknloop2 2)))))))

;; ===================================================

(defmethod! cps->identity ((hexany list))
:initvals ' (1 3 5 7)      
:indoc ' ("harmonicos")
:outdoc ' ("identities")
:icon 006
:doc ""

(loop for cknloop in hexany collect (reduce #'* cknloop)))

;; ===================================================

(defmethod! cps-chords ((vals list) (n number))
:initvals ' ((1 3 5 7) 4)      
:indoc ' ("Hexa" "chord-notes")
:outdoc ' ("chords")
:icon 006
:doc ""

(let* 

((action0 
(loop for cknloop in vals collect (reduce #'* cknloop)))

(ckn-action (loop for cknloop2 in action0 collect (/ cknloop2 (expt 2 (floor (log cknloop2 2))))))

(combinations (let ((n (1- n)))
    (combx ckn-action n)))



  (action1 (loop for cknloop in combinations collect 

        (let* ((ordem (sort-list cknloop))
               (iguais (let ((L()))
                         (loop for x from 0 to (1- (length ordem)) do
                               (when (not (equal (nth (+ x 1) ordem) (nth x ordem)))
                                 (push (nth x ordem) L)))
                         (reverse L)))
          (final (if (om= (length iguais) n) iguais nil))) (remove nil final)))))


(remove-duplicates (remove nil action1) :test #'equal)))


;; ;; =================================== Temperament =======================================

(defmethod! mk-temperament ((fund number)(ratio number) (division number))
:initvals ' (6000 2 24)     
:indoc ' ("inicial-note" "interval: 2 for octave, 3/2 for a fifth division, etc" "divison for the interval, for example: 24 divison of the octave")
:icon 004
:doc "create a temperament"

(x-append fund (f->mc (om* (mc->f fund) (om^ (expt ratio (om/ 1 division)) (arithm-ser 1 division 1))))))


;; ;; =================================== Math =============================================

(defmethod! Prime-decomposition ((harmonic number))
:initvals ' (9)     
:indoc ' ("number or list of the harmonics/parcials.")
:outdoc ' ("Prime-decomposition" "Prime-decomposition without the 2 that represents the octave interval")
:icon 004
:doc "Do the Prime-decomposition"
:numouts 2 

(defun factor (n)
  "Return a list of factors of N."
  (when (> n 1)
    (loop with max-d = (isqrt n)
	  for d = 2 then (if (evenp d) (+ d 1) (+ d 2)) do
	  (cond ((> d max-d) (return (list n))) ; n is prime
		((zerop (rem n d)) (return (cons d (factor (truncate n d)))))))))


(values 
 ((factor harmonic)) 
 (let* ((action1 (factor harmonic))) (remove 2 action1))))

(defmethod! Prime-decomposition ((harmonic list))
:initvals ' (9)     
:indoc ' ("inicial-note")
:outdoc ' ("Prime-decomposition" "Prime-decomposition without the 2 that represents the octave interval")
:icon 004
:doc "Do the Prime-decomposition"
:numouts 2 

(defun factor (n)
  "Return a list of factors of N."
  (when (> n 1)
    (loop with max-d = (isqrt n)
	  for d = 2 then (if (evenp d) (+ d 1) (+ d 2)) do
	  (cond ((> d max-d) (return (list n))) ; n is prime
		((zerop (rem n d)) (return (cons d (factor (truncate n d)))))))))


(values 
(loop :for x :in harmonic :collect (factor x))
(loop :for x :in harmonic :collect (let* ((action1 (factor x))) (remove 2 action1)))))


;; ;; =================================== Others =============================================

(defmethod! send-max ((maxlist list))
:initvals ' (6000 2 24)     
:indoc ' ("list")
:icon 007
:doc "Send for MAX/MSP. See the patch CKN-OSCreceive"

(osc-send (x-append "om/max" maxlist) "127.0.0.1" 7839))

;; ===================================================

(defmethod! mc->max ((maxlist list))
:initvals ' (6000)     
:indoc ' ("list of midicents")
:icon 007
:doc "Convert midicents in MIDI."

(loop for y in maxlist collect (* 0.01 y)))

;; ===================================================

(defmethod! gizmo ((note list) (fund number))
:initvals ' ((6386) (6000))    
:indoc ' ("list of midicents" "fund of the gizmo")
:icon 007
:doc "Convert midicents for the max object gizmo~."

(om* 0.01 (om- note fund)))

;; ===================================================

;; By Jordana Dias Paes Possani de Sousa and Charles K. Neimog | copyright © 2020
(defmethod! apex-vibro ((freq number))
:initvals ' (440)
:indoc ' ("valor da frequência") 
:icon 008
:doc "diz o valor da distância em mm entre o ápice da cóclea e o ponto de vibração de uma determinada frequencia"

(om/ (log (/ freq 165) 10) 0.06))


; =================================== Functions of Others OM libraries ================


; I will put some Libraries here for do the use more simple for people that don't know how OpenMusic work.


; =================================== COMBINE BY MIKHAIL MALT (IRCAM 1993-1996) ================



(defun cartesian-op (l1 l2 fun) 

  (mapcar #'(lambda (x) (mapcar #'(lambda (y) (funcall fun x y)) (list! l2))) (list! l1)))

(defun combx (vals n)
  (cond
   ((<=  n 0) vals)
   (t (flat-once 
       (cartesian-op vals (combx vals (1- n)) 'x-append)))))


(defun removeIt (a lis)
  (if (null lis) 0
      (if (= a (car lis))
          (delete (car lis))
          (removeIt (cdr lis)))))

;; ;; =================================== NUMBERS ===========================================

;; ==================PASCAL TRIANGULE ======================

(defun pascal (n)
   (genrow n '(1)))
 
(defun genrow (n l)
   (when (< 0 n)
       (print l)
       (genrow (1- n) (cons 1 (newrow l)))))
 
(defun newrow (l)
   (if (> 2 (length l))
      '(1)
      (cons (+ (car l) (cadr l)) (newrow (cdr l)))))
