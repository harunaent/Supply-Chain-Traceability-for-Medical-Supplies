;; Medical Supply Chain - Manufacturer Verification Contract
;; This contract validates legitimate producers of medical supplies

(define-data-var contract-owner principal tx-sender)

;; Map of verified manufacturers
(define-map verified-manufacturers principal
  {
    name: (string-utf8 100),
    license-number: (string-utf8 50),
    verified-at: uint,
    active: bool
  }
)

;; Public function to register a new manufacturer (only contract owner)
(define-public (register-manufacturer
    (manufacturer principal)
    (name (string-utf8 100))
    (license-number (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (asserts! (is-none (map-get? verified-manufacturers manufacturer)) (err u100))
    (ok (map-set verified-manufacturers
      manufacturer
      {
        name: name,
        license-number: license-number,
        verified-at: block-height,
        active: true
      }
    ))
  )
)

;; Public function to verify if a manufacturer is legitimate
(define-read-only (is-verified-manufacturer (manufacturer principal))
  (match (map-get? verified-manufacturers manufacturer)
    manufacturer-data (and (get active manufacturer-data) true)
    false
  )
)

;; Public function to deactivate a manufacturer
(define-public (deactivate-manufacturer (manufacturer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (match (map-get? verified-manufacturers manufacturer)
      manufacturer-data
        (ok (map-set verified-manufacturers
          manufacturer
          (merge manufacturer-data { active: false })
        ))
      (err u404)
    )
  )
)

;; Public function to reactivate a manufacturer
(define-public (reactivate-manufacturer (manufacturer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (match (map-get? verified-manufacturers manufacturer)
      manufacturer-data
        (ok (map-set verified-manufacturers
          manufacturer
          (merge manufacturer-data { active: true })
        ))
      (err u404)
    )
  )
)

;; Public function to get manufacturer details
(define-read-only (get-manufacturer-details (manufacturer principal))
  (map-get? verified-manufacturers manufacturer)
)

;; Function to transfer contract ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ok (var-set contract-owner new-owner))
  )
)
