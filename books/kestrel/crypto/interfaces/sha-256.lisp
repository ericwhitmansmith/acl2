; Cryptographic Library
;
; Copyright (C) 2019 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "CRYPTO")

(include-book "definterface-hash")
(include-book "kestrel/fty/byte-list32" :dir :system)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(definterface-hash sha-256
  :input-size-limit (expt 2 64)
  :output-size 256
  :parents (interfaces)
  :short "SHA-256 interface."
  :long
  (xdoc::topstring
   (xdoc::p
    "SHA-256 is specified in the "
    (xdoc::a :href "https://csrc.nist.gov/publications/detail/fips/180/4/final"
      "FIPS PUB 180-4 standard")
    ".")
   (xdoc::p
    "According to FIPS PUB 180-4,
     the input of SHA-256 is a sequence of less than @($2^{64}$) bits,
     or less than @($2^{61}$) bytes.")
   (xdoc::p
    "According to FIPS PUB 180-4,
     the output of SHA-256 is a sequence of exactly 256 bits, or 32 bytes.")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defsection sha-256-interface-ext
  :extension sha-256-interface

  (defrule byte-list32p-of-sha-256-bytes
    (byte-list32p (sha-256-bytes bytes))
    :enable byte-list32p))
