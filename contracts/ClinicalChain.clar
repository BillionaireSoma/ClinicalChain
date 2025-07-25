;; ClinicalChain: Clinical Trial Registry and Protocol Management System
;; Version: 1.0.0

(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-TRIAL-NOT-FOUND (err u2))
(define-constant ERR-ALREADY-REGISTERED (err u3))
(define-constant ERR-INVALID-STATUS (err u4))
(define-constant ERR-INVALID-PARTICIPANT-COUNT (err u5))
(define-constant ERR-INVALID-TRIAL-PHASE (err u6))
(define-constant ERR-INVALID-STUDY-TYPE (err u7))
(define-constant ERR-INVALID-TRIAL-TITLE (err u8))
(define-constant ERR-INVALID-PROTOCOL (err u9))

(define-constant MIN-PARTICIPANT-COUNT u5)

(define-data-var next-trial-id uint u1)

(define-map trial-registry
    uint
    {
        investigator: principal,
        trial-title: (string-utf8 50),
        protocol: (string-utf8 200),
        trial-phase: (string-utf8 15),
        study-type: (string-utf8 10),
        enrollment-status: (string-utf8 15),
        participant-count: uint
    })

(define-private (validate-trial-phase (trial-phase (string-utf8 15)))
    (or 
        (is-eq trial-phase u"Preclinical")
        (is-eq trial-phase u"Phase I")
        (is-eq trial-phase u"Phase II")
        (is-eq trial-phase u"Phase III")
        (is-eq trial-phase u"Phase IV")
        (is-eq trial-phase u"Observational")
    ))

(define-private (validate-study-type (study-type (string-utf8 10)))
    (or 
        (is-eq study-type u"RCT")
        (is-eq study-type u"Cohort")
        (is-eq study-type u"Case-Control")
        (is-eq study-type u"Cross-Over")
        (is-eq study-type u"Pilot")
    ))

(define-private (validate-text-input (text (string-utf8 200)) (min-length uint) (max-length uint))
    (let 
        (
            (text-length (len text))
        )
        (and 
            (>= text-length min-length)
            (<= text-length max-length)
        )
    ))

(define-public (register-trial 
    (trial-title (string-utf8 50))
    (protocol (string-utf8 200))
    (trial-phase (string-utf8 15))
    (study-type (string-utf8 10))
    (participant-count uint))
    (let
        (
            (trial-id (var-get next-trial-id))
        )
        (asserts! (validate-text-input trial-title u3 u50) ERR-INVALID-TRIAL-TITLE)
        (asserts! (validate-text-input protocol u10 u200) ERR-INVALID-PROTOCOL)
        (asserts! (>= participant-count MIN-PARTICIPANT-COUNT) ERR-INVALID-PARTICIPANT-COUNT)
        (asserts! (validate-trial-phase trial-phase) ERR-INVALID-TRIAL-PHASE)
        (asserts! (validate-study-type study-type) ERR-INVALID-STUDY-TYPE)
        
        (map-set trial-registry trial-id {
            investigator: tx-sender,
            trial-title: trial-title,
            protocol: protocol,
            trial-phase: trial-phase,
            study-type: study-type,
            enrollment-status: u"recruiting",
            participant-count: participant-count
        })
        (var-set next-trial-id (+ trial-id u1))
        (ok trial-id)
    ))

(define-public (complete-enrollment (trial-id uint))
    (let
        (
            (trial (unwrap! (map-get? trial-registry trial-id) ERR-TRIAL-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender (get investigator trial)) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (get enrollment-status trial) u"recruiting") ERR-INVALID-STATUS)
        (ok (map-set trial-registry trial-id (merge trial { enrollment-status: u"completed" })))
    ))

(define-read-only (get-trial (trial-id uint))
    (ok (map-get? trial-registry trial-id)))

(define-read-only (get-investigator (trial-id uint))
    (ok (get investigator (unwrap! (map-get? trial-registry trial-id) ERR-TRIAL-NOT-FOUND))))

(define-read-only (get-total-trials)
    (ok (- (var-get next-trial-id) u1)))

(define-read-only (get-enrollment-status (trial-id uint))
    (ok (get enrollment-status (unwrap! (map-get? trial-registry trial-id) ERR-TRIAL-NOT-FOUND))))