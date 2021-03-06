; ABNF (Excluding Examples)
;
; Copyright (C) 2019 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ABNF")

; the order of the following INCLUDE-BOOKs determines
; the order of the subtopics of the ABNF topic below:
(include-book "abstract-syntax")
(include-book "semantics")
(include-book "operations")
(include-book "core-rules")
(include-book "concrete-syntax")
(include-book "parser")
(include-book "abstractor")
(include-book "parser-and-abstractor-validation")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc+ abnf

  :parents (acl2::kestrel-books acl2::projects)

  :short "A library for ABNF (Augmented Backus-Naur Form)."

  :long

  "<p>
   ABNF is a standardized formal grammar notation
   used in several Internet syntax specifications,
   e.g.
   <a href=\"https://www.rfc-editor.org/info/rfc3986\">URI</a>,
   <a href=\"https://www.rfc-editor.org/info/rfc7230\">HTTP</a>,
   <a href=\"https://www.rfc-editor.org/info/rfc5322\">IMF</a>,
   <a href=\"https://www.rfc-editor.org/info/rfc5321\">SMTP</a>,
   <a href=\"https://www.rfc-editor.org/info/rfc3501\">IMAP</a>, and
   <a href=\"https://www.rfc-editor.org/info/rfc7159\">JSON</a>.
   ABNF is specified by
   <a href=\"https://www.rfc-editor.org/info/rfc5234\">RFC 5234</a> and
   <a href=\"https://www.rfc-editor.org/info/rfc7405\">RFC 7405</a>;
   the latter updates two portions of the former.
   The syntax of ABNF is specified in ABNF itself.
   </p>

   <p>
   This ACL2 library provides:
   </p>
   <ul>
     <li>
     A formalization of the syntax and semantics of the ABNF notation.
     </li>
     <li>
     A verified parser that turns ABNF grammar text
     (e.g. from the HTTP RFC)
     into a formal representation suitable for formal specification
     (e.g. for HTTP parsing).
     </li>
     <li>
     Executable operations on ABNF grammars,
     e.g. to check their well-formedness and to compose them.
     </li>
     <li>
     Examples of use of the parser, the abstractor, and some grammar operations
     on a few real-world ABNF grammars (e.g. for HTTP).
     </li>
   </ul>

   <p>
   In the documentation of this library,
   `[RFC]' refers to the result of updating RFC 5234 as specified by RFC 7405.
   Sections and subsections of [RFC] are referenced
   by appending their designations separated by colon:
   for example, `[RFC:3]' refers to Section 3 of RFC 5234.
   As another example, `[RFC:2.3]' refers to
   the result of updating Section 2.3 of RFC 5234
   as specified in Section 2.1 of RFC 7405.
   These square-bracketed references may be used
   as nouns or parenthetically.
   </p>

   <p>
   The <a href=\"https://www.kestrel.edu/home/people/coglio/vstte18.pdf\"
   >VSTTE 2018 paper
   ``A Formalization of the ABNF Notation
   and a Verified Parser of ABNF Grammars''</a>
   by Alessandro Coglio
   provides an overview
   of the formalization of the ABNF notation
   and of the verified parser
   (but not of the operations on ABNF grammars).
   The differences between the paper and the ABNF library
   are described <see topic='@(url differences-with-paper)'>here</see>.
   </p>"

  :order-subtopics t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc differences-with-paper

  :parents (abnf)

  :short "Differences with the paper."

  :long

  "<p>
   For brevity, the paper makes the following slight simplfications
   compared to the ABNF library:
   </p>

   <ul>

     <li>
     The forms in the paper omit
     guards,
     rule classes,
     measures,
     hints,
     keyed options for documentation (e.g. @(':short')),
     and some keyed options for
     <see topic='@(url fty::fty)'>FTY</see> types (e.g. @(':pred')).
     </li>

     <li>
     The paper uses
     @(tsee defun),
     @(tsee mutual-recursion),
     @(tsee defthm), and
     @(tsee defun-sk)
     instead of
     @(tsee define),
     @(tsee defines),
     @(tsee defrule), and
     @(tsee define-sk).
     </li>

     <li>
     The paper uses slightly shorter names
     for the parameters of some functions
     (e.g. @('alt') instead of @('alternation')).
     </li>

     <li>
     The paper uses @('*abnf-grammar*')
     as the name of the constant @(tsee *all-concrete-syntax-rules*).
     </li>

   </ul>")
