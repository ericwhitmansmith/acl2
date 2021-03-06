; Copyright (C) 2013, Regents of the University of Texas
; Written by Bob Boyer and Warren A. Hunt, Jr. (some years before that)
; License: A 3-clause BSD license.  See the LICENSE file distributed with ACL2.

; gentle.lisp                                 Boyer & Hunt

; Jared took these functions out of hons-help.lisp since they (generally) don't
; have anything to do with hons.


(in-package "ACL2")

(defabbrev gentle-car    (x) (if (consp x) (car x) nil))
(defabbrev gentle-cdr    (x) (if (consp x) (cdr x) nil))
(defabbrev gentle-caar   (x) (gentle-car (gentle-car x)))
(defabbrev gentle-cadr   (x) (gentle-car (gentle-cdr x)))
(defabbrev gentle-cdar   (x) (gentle-cdr (gentle-car x)))
(defabbrev gentle-cddr   (x) (gentle-cdr (gentle-cdr x)))
(defabbrev gentle-caaar  (x) (gentle-car (gentle-caar x)))
(defabbrev gentle-cadar  (x) (gentle-car (gentle-cdar x)))
(defabbrev gentle-cdaar  (x) (gentle-cdr (gentle-caar x)))
(defabbrev gentle-cddar  (x) (gentle-cdr (gentle-cdar x)))
(defabbrev gentle-caadr  (x) (gentle-car (gentle-cadr x)))
(defabbrev gentle-caddr  (x) (gentle-car (gentle-cddr x)))
(defabbrev gentle-cdadr  (x) (gentle-cdr (gentle-cadr x)))
(defabbrev gentle-cdddr  (x) (gentle-cdr (gentle-cddr x)))

; [Jared] BOZO I'd kind of prefer not to define any of the following, since at
; four levels of consing you're really getting into unreadable territory.

(defabbrev gentle-caaaar (x) (gentle-car (gentle-caaar x)))
(defabbrev gentle-cadaar (x) (gentle-car (gentle-cdaar x)))
(defabbrev gentle-cdaaar (x) (gentle-cdr (gentle-caaar x)))
(defabbrev gentle-cddaar (x) (gentle-cdr (gentle-cdaar x)))
(defabbrev gentle-caadar (x) (gentle-car (gentle-cadar x)))
(defabbrev gentle-caddar (x) (gentle-car (gentle-cddar x)))
(defabbrev gentle-cdadar (x) (gentle-cdr (gentle-cadar x)))
(defabbrev gentle-cdddar (x) (gentle-cdr (gentle-cddar x)))
(defabbrev gentle-caaadr (x) (gentle-car (gentle-caadr x)))
(defabbrev gentle-cadadr (x) (gentle-car (gentle-cdadr x)))
(defabbrev gentle-cdaadr (x) (gentle-cdr (gentle-caadr x)))
(defabbrev gentle-cddadr (x) (gentle-cdr (gentle-cdadr x)))
(defabbrev gentle-caaddr (x) (gentle-car (gentle-caddr x)))
(defabbrev gentle-cadddr (x) (gentle-car (gentle-cdddr x)))
(defabbrev gentle-cdaddr (x) (gentle-cdr (gentle-caddr x)))
(defabbrev gentle-cddddr (x) (gentle-cdr (gentle-cdddr x)))

(defn gentle-revappend (x y)
  (mbe :logic (revappend x y)
       :exec (if (atom x)
                 y
               (gentle-revappend (cdr x) (cons (car x) y)))))

(defn gentle-reverse (x)
  (mbe :logic (reverse x)
       :exec (if (stringp x)
                 (reverse x)
               (gentle-revappend x nil))))

(defn gentle-strip-cars (l)

; [Jared]: BOZO consider changing this so that it agrees with strip-cars in the
; recursive case.  This would allow us to avoid introducing a new, incompatible
; concept.

  (if (atom l)
      nil
    (cons (if (atom (car l))
              (car l)
            (car (car l)))
          (gentle-strip-cars (cdr l)))))

(defn gentle-strip-cdrs (l)

; [Jared]: BOZO same comment as gentle-strip-cars.

  (if (atom l)
      nil
    (cons (if (atom (car l))
              (car l)
            (cdr (car l)))
          (gentle-strip-cdrs (cdr l)))))


(defn gentle-member-eq (x y)
  (declare (xargs :guard (symbolp x)))
  (mbe :logic (member-equal x y)
       :exec (cond ((atom y) nil)
                   ((eq x (car y)) y)
                   (t (gentle-member-eq x (cdr y))))))

(defn gentle-member-eql (x y)
  (declare (xargs :guard (eqlablep x)))
  (mbe :logic (member-equal x y)
       :exec (cond ((atom y) nil)
                   ((eql x (car y)) y)
                   (t (gentle-member-eql x (cdr y))))))

(defn gentle-member-equal (x y)

; [Jared]: BOZO I find the use of hons-equal kind of odd here.  My objection is
; merely that hons stuff is "spilling over" into these gentle definitions that
; wouldn't appear to have any connection to hons just by their names.

  (mbe :logic (member-equal x y)
       :exec (cond ((atom y) nil)
                   ((equal x (car y)) y)
                   (t (gentle-member-equal x (cdr y))))))

(defn gentle-member (x y)
  (mbe :logic (member-equal x y)
       :exec (cond ((symbolp x) (gentle-member-eq x y))
                   ((or (characterp x) (acl2-numberp x))
                    (gentle-member-eql x y))
                   (t (gentle-member-equal x y)))))

(defn gentle-last (l)
  (mbe :logic (last l)
       :exec (if (or (atom l) (atom (cdr l)))
                 l
               (gentle-last (cdr l)))))



(defn gentle-take (n l)

 "Unlike TAKE, GENTLE-TAKE fills at the end with NILs, if necessary, to
 always return a list n long."

; [Jared]: Note that previously this function had a very strange hons/cons
; behavior; most of the list it created was conses, but if we hit the base
; case, the list of NILs were HONSes because of const-list-acc being used.  I
; changed this to use an ordinary make-list in the base case, so now the list
; it returns is always composed entirely of conses.

 (cond ((not (posp n))
        nil)
       ((atom l)
        (make-list n))
       (t
        (cons (car l)
              (gentle-take (1- n) (cdr l))))))

(defthm true-listp-of-make-list-ac
  (equal (true-listp (make-list-ac n val ac))
         (true-listp ac))
  :rule-classes ((:rewrite)
                 (:type-prescription
                  :corollary
                  (implies (true-listp ac)
                           (true-listp (make-list-ac n val ac))))))

(defthm true-listp-of-gentle-take
  (true-listp (gentle-take n l))
  :rule-classes :type-prescription)



; (mu-defn ...) is like (mutual-recursion ...), but for a list of "defn" rather
; than "defun" calls.

(defn defnp (x)
  (and (consp x)
       (symbolp (car x))
       (eq (car x) 'defn)
       (consp (cdr x))
       (symbolp (cadr x))
       (consp (cddr x))
       (symbol-listp (caddr x))
       (consp (cdddr x))
       (true-listp (cdddr x))))

(defn defn-listp (x)
  (if (atom x)
      (null x)
    (and (defnp (car x))
         (defn-listp (cdr x)))))

(defun mu-defn-fn (l)
  (declare (xargs :guard (defn-listp l)))
  (if (atom l) nil
    (cons `(defun
             ,(cadr (car l))
             ,(caddr (car l))
             (declare (xargs :guard t))
             ,@(cdddr (car l)))
          (mu-defn-fn (cdr l)))))

(defmacro mu-defn (&rest l)
  `(mutual-recursion ,@(mu-defn-fn l)))



