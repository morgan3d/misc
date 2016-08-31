(require-library "functio.ss")

;; infix->prefix: '(iexp) -> pexp
;;
;; Recursive descent infix parser for Scheme.  Used to implement
;; the infix macro.
;; 
;; iexp: iexp op iexp | unop iexp | symbol | number | (iexp)
;; pexp: number | symbol | (op pexp pexp) | (unop pexp) 
;; op:   + | * | - | / | ^ | > | < | = | <= | >= | and | or | modulo
;; unop: sqrt | cos | sin | tan | - | not | + | atan | acos | asin
;;
;; Morgan McGuire
;; morgan@cs.brown.edu
(define (infix->prefix iexp)
  (if (not (list? iexp))
      
      (error 'infix->prefix "Argument must be a parse-tree")
      
      (letrec
        ;; The operator precedence rules (from C).  Lowest precedence is
        ;; first.  Operators of equal precedence are on the same line.  All
        ;; operators must be binary; unary minus and NOT are handled
        ;; specially within the parser.  Note that you may not call prefix
        ;; functions within an infix form; the parser wouldn't know what to
        ;; do.  Also note that AND and OR are treated as operators but their
        ;; special form status is not affected.
        ([precedence '((or)
                       (and)
                       (> < >= <= =)
                       (+ -)
                       (* / modulo)
                       number-or-variable)]
         
         [unary-operator '(- + not sqrt cos sin tan atan acos asin)]
                                 
        ;; peek-token: void -> token
        [peek-token (lambda () (first tokens))]
        
        ;; pop-token: void->token
        ;; Removes a token.
        [pop-token (lambda ()
                     (let ([t (first tokens)])
                       (begin
                         (set! tokens (rest tokens))
                         t)))]
        
        
        ;; more-tokens?: void -> bool
        [more-tokens? (lambda () (not (empty? tokens)))]
        
        ;; while: alpha x (void->bool) x (alpha->alpha) -> void
        ;; Repeats body while test returns true.  Works like FOLD except 
        ;; the test indicates when it is done instead of iterating over
        ;; a list.
        [while      (lambda (init test? body)
                      (if (test?)
                          (while (body init) test? body)
                          init))]
        
        ;; parse-infix: (list operator) x (list (list operator)) -> pexp
        ;; low is a set of equally low precedence operators, high-set is a
        ;; list of lists of higher precedence operators.
        [parse-infix 
         (lambda (low high-set)
           (if (eq? low 'number-or-variable)
               
               (let ([left (pop-token)])
                 
                 ;; At the highest precedence, just return the next token or
                 ;; expression.
                 (cond 
                   ;; Parenthesized expression; recursively parse it
                   [(list? left)        (infix->prefix left)]
                     
                   ;; Unary operator
                   [(memq left unary-operator) 
                    `(,left ,(parse-infix low high-set))]

                   ;; Number or symbol
                   [else left]))
                   
               ;; At this level of precedence, parse two higher level
               ;; expressions and combine them.
               (while (parse-infix (first high-set) (rest high-set))
                      (lambda () (and (more-tokens?) (memq (peek-token) low)))
                      (lambda (left) 
                        (let* ([operator (pop-token)]
                               [right    (parse-infix (first high-set) 
                                                      (rest high-set))])
                          `(,operator ,left ,right))))))]
        
        [tokens iexp]) 
        
        (parse-infix (first precedence)
                     (rest precedence)))))

;; Infix math macro for PLT MzScheme and DrScheme/(full Scheme mode).  Only 
;; grouping parens and the following functions are supported in infix form:
;;
;;  +  *  -  /  ^  >  <  =  <=  >= and or sqrt cos sin tan not modulo
;;
;; Morgan McGuire
;; morgan@cs.brown.edu
(define-macro infix (lambda (a . b) (infix->prefix (cons a b))))

(define test1 '((-(1 + z) * 3 ^ 4 < y + 2) or (2 + x > y))) 
;(pretty-print (infix->prefix test1))

(infix 1 + 2 * 3)
