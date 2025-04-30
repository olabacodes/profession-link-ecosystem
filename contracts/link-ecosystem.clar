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

;; Modify an existing expert's profile information
(define-public (modify-expert-profile 
    (identity-name (string-ascii 100))
    (capabilities (list 10 (string-ascii 50)))
    (location-region (string-ascii 100))
    (professional-history (string-ascii 500)))
    (let
        (
            (user-principal tx-sender)
            (existing-profile (map-get? expert-registry user-principal))
        )
        ;; Confirm profile exists before attempting modification
        (if (is-some existing-profile)
            (begin
                ;; Validate all required fields have appropriate content
                (if (or (is-eq identity-name "")
                        (is-eq location-region "")
                        (is-eq (len capabilities) u0)
                        (is-eq professional-history ""))
                    (err ERR-INVALID-HISTORY)
                    (begin
                        ;; Update the expert's profile with new information
                        (map-set expert-registry user-principal
                            {
                                identity-name: identity-name,
                                capabilities: capabilities,
                                location-region: location-region,
                                professional-history: professional-history
                            }
                        )
                        (ok "Expert profile successfully modified.")
                    )
                )
            )
            (err ERR-ENTITY-MISSING)
        )
    )
)


;; ================== PROJECT LISTING OPERATIONS ==================

;; Create a new project opportunity listing
(define-public (publish-project-listing 
    (role-title (string-ascii 100))
    (role-description (string-ascii 500))
    (location-region (string-ascii 100))
    (required-capabilities (list 10 (string-ascii 50))))
    (let
        (
            (creator-principal tx-sender)
            (existing-listing (map-get? project-listings creator-principal))
        )
        ;; Verify listing doesn't already exist for this principal
        (if (is-none existing-listing)
            (begin
                ;; Ensure all required project fields are valid
                (if (or (is-eq role-title "")
                        (is-eq role-description "")
                        (is-eq location-region "")
                        (is-eq (len required-capabilities) u0))
                    (err ERR-INVALID-PROJECT)
                    (begin
                        ;; Store the new project listing
                        (map-set project-listings creator-principal
                            {
                                role-title: role-title,
                                role-description: role-description,
                                creator-id: creator-principal,
                                location-region: location-region,
                                required-capabilities: required-capabilities
                            }
                        )
                        (ok "Project listing successfully published to network.")
                    )
                )
            )
            (err ERR-ALREADY-EXISTS)
        )
    )
)

;; Update an existing project listing with new information
(define-public (modify-project-listing 
    (role-title (string-ascii 100))
    (role-description (string-ascii 500))
    (location-region (string-ascii 100))
    (required-capabilities (list 10 (string-ascii 50))))
    (let
        (
            (creator-principal tx-sender)
            (existing-listing (map-get? project-listings creator-principal))
        )
        ;; Confirm project listing exists before attempting update
        (if (is-some existing-listing)
            (begin
                ;; Ensure all required fields are valid
                (if (or (is-eq role-title "")
                        (is-eq role-description "")
                        (is-eq location-region "")
                        (is-eq (len required-capabilities) u0))
                    (err ERR-INVALID-PROJECT)
                    (begin
                        ;; Update the project listing with new information
                        (map-set project-listings creator-principal
                            {
                                role-title: role-title,
                                role-description: role-description,
                                creator-id: creator-principal,
                                location-region: location-region,
                                required-capabilities: required-capabilities
                            }
                        )
                        (ok "Project listing successfully updated in network.")
                    )
                )
            )
            (err ERR-ENTITY-MISSING)
        )
    )
)

;; Remove a project listing from the network
(define-public (withdraw-project-listing)
    (let
        (
            (creator-principal tx-sender)
            (existing-listing (map-get? project-listings creator-principal))
        )
        ;; Confirm project listing exists before attempting removal
        (if (is-some existing-listing)
            (begin
                ;; Permanently delete the project listing
                (map-delete project-listings creator-principal)
                (ok "Project listing successfully withdrawn from network.")
            )
            (err ERR-ENTITY-MISSING)
        )
    )
)


;; ================== ORGANIZATION OPERATIONS ==================

;; Modify an existing organization's profile information
(define-public (modify-organization-profile 
    (entity-title (string-ascii 100))
    (industry-category (string-ascii 50))
    (location-region (string-ascii 100)))
    (let
        (
            (org-principal tx-sender)
            (existing-org (map-get? organization-registry org-principal))
        )
        ;; Confirm organization profile exists before attempting modification
        (if (is-some existing-org)
            (begin
                ;; Validate all required fields
                (if (or (is-eq entity-title "")
                        (is-eq industry-category "")
                        (is-eq location-region ""))
                    (err ERR-INVALID-REGION)
                    (begin
                        ;; Update the organization profile with new information
                        (map-set organization-registry org-principal
                            {
                                entity-title: entity-title,
                                industry-category: industry-category,
                                location-region: location-region
                            }
                        )
                        (ok "Organization profile successfully modified.")
                    )
                )
            )
            (err ERR-ENTITY-MISSING)
        )
    )
)

;; Permanently remove an organization's profile from the network
(define-public (deactivate-organization-profile)
    (let
        (
            (org-principal tx-sender)
            (existing-org (map-get? organization-registry org-principal))
        )
        ;; Confirm organization exists before attempting removal
        (if (is-some existing-org)
            (begin
                ;; Permanently delete the organization profile
                (map-delete organization-registry org-principal)
                (ok "Organization profile successfully deactivated from network.")
            )
            (err ERR-ENTITY-MISSING)
        )
    )
)

;; Establish a new organization profile in the network
(define-public (register-organization-profile 
    (entity-title (string-ascii 100))
    (industry-category (string-ascii 50))
    (location-region (string-ascii 100)))
    (let
        (
            (org-principal tx-sender)
            (existing-org (map-get? organization-registry org-principal))
        )
        ;; Verify organization doesn't already have a profile
        (if (is-none existing-org)
            (begin
                ;; Validate all required organization fields
                (if (or (is-eq entity-title "")
                        (is-eq industry-category "")
                        (is-eq location-region ""))
                    (err ERR-INVALID-REGION)
                    (begin
                        ;; Commit the new organization profile to storage
                        (map-set organization-registry org-principal
                            {
                                entity-title: entity-title,
                                industry-category: industry-category,
                                location-region: location-region
                            }
                        )
                        (ok "Organization profile successfully registered in network.")
                    )
                )
            )
            (err ERR-ALREADY-EXISTS)
        )
    )
)


