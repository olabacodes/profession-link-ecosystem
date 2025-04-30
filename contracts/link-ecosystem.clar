;; Profession Link Ecosystem
;;
;; A decentralized platform facilitating connections between individual professionals
;; and organizations seeking expertise across various domains.



;; ================== ERROR CODE DEFINITIONS ==================

(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-EXISTS (err u409))
(define-constant ERR-INVALID-CAPABILITIES (err u400))
(define-constant ERR-INVALID-REGION (err u401))
(define-constant ERR-INVALID-HISTORY (err u402))
(define-constant ERR-INVALID-PROJECT (err u403))
(define-constant ERR-ENTITY-MISSING (err u404))


;; ================== STORAGE STRUCTURES ==================

;; Repository for available project listings
(define-map project-listings
    principal
    {
        role-title: (string-ascii 100),
        role-description: (string-ascii 500),
        creator-id: principal,
        location-region: (string-ascii 100),
        required-capabilities: (list 10 (string-ascii 50))
    }
)

;; Repository for individual expert data records
(define-map expert-registry
    principal
    {
        identity-name: (string-ascii 100),
        capabilities: (list 10 (string-ascii 50)),
        location-region: (string-ascii 100),
        professional-history: (string-ascii 500)
    }
)

;; Repository for organization records
(define-map organization-registry
    principal
    {
        entity-title: (string-ascii 100),
        industry-category: (string-ascii 50),
        location-region: (string-ascii 100)
    }
)


;; ================== EXPERT PROFILE OPERATIONS ==================

;; Establish a new professional expert profile in the network
(define-public (register-expert-profile 
    (identity-name (string-ascii 100))
    (capabilities (list 10 (string-ascii 50)))
    (location-region (string-ascii 100))
    (professional-history (string-ascii 500)))
    (let
        (
            (user-principal tx-sender)
            (existing-profile (map-get? expert-registry user-principal))
        )
        ;; Verify this expert doesn't already have a profile
        (if (is-none existing-profile)
            (begin
                ;; Validate all required profile fields have appropriate content
                (if (or (is-eq identity-name "")
                        (is-eq location-region "")
                        (is-eq (len capabilities) u0)
                        (is-eq professional-history ""))
                    (err ERR-INVALID-HISTORY)
                    (begin
                        ;; Commit the new expert profile to storage
                        (map-set expert-registry user-principal
                            {
                                identity-name: identity-name,
                                capabilities: capabilities,
                                location-region: location-region,
                                professional-history: professional-history
                            }
                        )
                        (ok "Expert profile successfully registered in network.")
                    )
                )
            )
            (err ERR-ALREADY-EXISTS)
        )
    )
)
