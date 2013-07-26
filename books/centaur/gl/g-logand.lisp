
(in-package "GL")

(include-book "g-if")
(include-book "g-primitives-help")
(include-book "symbolic-arithmetic-fns")
(include-book "eval-g-base")
;(include-book "tools/with-arith5-help" :dir :system)
(local (include-book "symbolic-arithmetic"))
(local (include-book "eval-g-base-help"))
(local (include-book "hyp-fix-logic"))
;(local (allow-arith5-help))


(defun g-binary-logand-of-numbers (x y)
  (declare (xargs :guard (and (general-numberp x)
                              (general-numberp y))))
  (b* (((mv xrn xrd xin xid)
        (general-number-components x))
       ((mv yrn yrd yin yid)
        (general-number-components y))
       ((mv xintp xintp-known)
        (if (equal xrd '(t))
            (mv (bfr-or (bfr-=-ss xin nil)
                      (bfr-=-uu xid nil)) t)
          (mv nil nil)))
       ((mv yintp yintp-known)
        (if (equal yrd '(t))
            (mv (bfr-or (bfr-=-ss yin nil)
                      (bfr-=-uu yid nil)) t)
          (mv nil nil))))
    (if (and xintp-known yintp-known)
        (mk-g-number
         (bfr-logand-ss (bfr-ite-bss-fn xintp xrn nil)
                    (bfr-ite-bss-fn yintp yrn nil)))
      (g-apply 'binary-logand (gl-list x y)))))

(in-theory (disable (g-binary-logand-of-numbers)))


(defthm deps-of-g-binary-logand-of-numbers
  (implies (and (not (gobj-depends-on k p x))
                (not (gobj-depends-on k p y))
                (general-numberp x)
                (general-numberp y))
           (not (gobj-depends-on k p (g-binary-logand-of-numbers x y)))))

(local (defthm logand-non-integers
         (and (implies (not (integerp i))
                       (equal (logand i j) (logand 0 j)))
              (implies (not (integerp j))
                       (equal (logand i j) (logand i 0))))))

(local (include-book "arithmetic/top-with-meta" :dir :system))

(local
 (progn
   ;; (defthm gobjectp-g-binary-logand-of-numbers
   ;;   (implies (and (gobjectp x)
   ;;                 (general-numberp x)
   ;;                 (gobjectp y)
   ;;                 (general-numberp y))
   ;;            (gobjectp (g-binary-logand-of-numbers x y)))
   ;;   :hints(("Goal" :in-theory (disable general-numberp
   ;;                                      general-number-components))))

   (defthm g-binary-logand-of-numbers-correct
     (implies (and (general-numberp x)
                   (general-numberp y))
              (equal (eval-g-base (g-binary-logand-of-numbers x y) env)
                     (logand (eval-g-base x env)
                             (eval-g-base y env))))
     :hints (("goal" :in-theory (e/d* ((:ruleset general-object-possibilities))
                                      (general-numberp
                                       general-number-components))
              :do-not-induct t)))))

(in-theory (disable g-binary-logand-of-numbers))


(def-g-binary-op binary-logand
  (b* ((i-num (if (general-numberp i) i 0))
       (j-num (if (general-numberp j) j 0)))
    (g-binary-logand-of-numbers i-num j-num)))

;; (def-gobjectp-thm binary-logand
;;   :hints `(("Goal" :in-theory (e/d* ()
;;                                     ((:definition ,gfn)
;;                                      general-concretep-def
;;                                      gobj-fix-when-not-gobjectp
;;                                      gobj-fix-when-gobjectp
;;                                      (:ruleset gl-wrong-tag-rewrites)
;;                                      (:rules-of-class :type-prescription :here)))
;;             :induct (,gfn i j . ,params)
;;             :expand ((,gfn i j . ,params)
;;                      (gobjectp (logand (gobj-fix i)
;;                                        (gobj-fix j)))))))

(verify-g-guards
 binary-logand
 :hints `(("Goal" :in-theory (disable* ,gfn
                                       general-concretep-def))))

(def-gobj-dependency-thm binary-logand
  :hints `(("goal" :induct ,gcall
            :expand (,gcall)
            :in-theory (disable (:d ,gfn)))))

(local (defthm logand-non-acl2-numbers
         (and (implies (not (acl2-numberp i))
                       (equal (logand i j) (logand 0 j)))
              (implies (not (acl2-numberp j))
                       (equal (logand i j) (logand i 0))))))

(def-g-correct-thm binary-logand eval-g-base
  :hints `(("Goal" :in-theory (e/d* (general-concretep-atom
                                     (:ruleset general-object-possibilities)
                                     not-general-numberp-not-acl2-numberp)
                                    ((:definition ,gfn)
                                     general-concretep-def
                                     binary-logand
                                     components-to-number-alt-def
                                     hons-assoc-equal
                                     default-car default-cdr
                                     (:rules-of-class :type-prescription :here)))
            :induct (,gfn i j . ,params)
            :do-not-induct t
            :expand ((,gfn i j . ,params)))))
