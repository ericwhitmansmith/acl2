; X86ISA Library

; Note: The license below is based on the template at:
; http://opensource.org/licenses/BSD-3-Clause

; Copyright (C) 2015, Regents of the University of Texas
; All rights reserved.

; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are
; met:

; o Redistributions of source code must retain the above copyright
;   notice, this list of conditions and the following disclaimer.

; o Redistributions in binary form must reproduce the above copyright
;   notice, this list of conditions and the following disclaimer in the
;   documentation and/or other materials provided with the distribution.

; o Neither the name of the copyright holders nor the names of its
;   contributors may be used to endorse or promote products derived
;   from this software without specific prior written permission.

; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
; HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

; Original Author(s):
; Shilpi Goel         <shigoel@cs.utexas.edu>

;; Simulation of a program that illustrates zero-copy --- the
;; destination linear address is mapped to the same physical address
;; as the source linear address.

(in-package "X86ISA")

(include-book "../../top" :ttags :all)
(include-book "readValues-addr-byte" :ttags :all)

;; ======================================================================

;; Initialize the system-level mode of operation
;; 1. Set the programmer-level mode to nil
;; 2. Set CR0.PG  = 1
;; 3. Set CR4.PAE = 1
;; 4. Set CR3.PDB = (logtail 12 address-of-pml4-table)
(init-sys-view
 ;; Address of PML4 Table
 0
 x86)

;; The default paging structures occupy 2,101,248 bytes (#x201000) and
;; are located at address 0. Since the program below exists in the
;; #x400*** space, there should be no overlap between the structures
;; and the program.

;; A simple sanity check:
(assert-event (equal (app-view x86) nil))

;; Set CPL = 0 (actually, it's 0 by default, which should change, maybe)
(!seg-visiblei *cs* (!seg-sel-layout-slice :rpl 0 (seg-visiblei *cs* x86)) x86)

;; Initialize the x86 state:
(init-x86-state
;; Status (MS and fault field)
 nil
;; Start Address --- set the RIP to this address
 #x400400
;; Halt Address --- overwrites this address by #xF4 (HLT)
 #x400440
;; Initial values of General-Purpose Registers
 '((#.*RSP* . #x7FFF5FBFF488))
;; Control Registers
 nil
;; Model-Specific Registers
 nil
;; Rflags Register
 #x2
;; Memory image
 *readValues*
;; x86 state
 x86)

;; A simple sanity check (should use rm08 here but memi works because
;; of the direct map from LA to PA):
(assert-event (equal (memi #x40043d x86) #x89))

(x86-break '(equal (rip x86) #x400430)) ;; Call to rewire_dst_to_src
(x86-break '(equal (rip x86) #x400680)) ;; First instruction of rewire_dst_to_src
(x86-break '(equal (rip x86) #x400435)) ;; Instruction in main following the call to rewire_dst_to_src
(x86-break '(equal (rip x86) #x40044d)) ;; rax should contain the value at 0x8c0000000 here.

;; We have a self-mapped page table setup.
(la-to-pa #x8c0000000  :r 0 x86) ;; == #x8c0000000
(la-to-pa #x900000000  :r 0 x86) ;; == #x900000000

(!log-file-name "readValues.log")
;; Record the x86 state at a breakpoint in the log file above and then continue:
(x86-debug!)

(ms x86)
;; If *rax* == 1, Success (la == pa).
(assert-event (equal (rgfi *rax* x86) '1))

(rm08 #x8c0000000 :r x86) ;; == #xF
(rm08 #x900000000 :r x86) ;; == #xF

;; ======================================================================
