;; Simple Rental Contract
;; Lock deposits for rentals until returned

;; Define constants
(define-constant err-invalid-amount (err u100))
(define-constant err-not-owner (err u101))
(define-constant err-no-deposit (err u102))

;; Store deposits: renter principal  deposit amount
(define-map deposits principal uint)

;; Function 1: Lock deposit (tenant sends STX to contract)
(define-public (lock-deposit (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set deposits tx-sender
             (+ (default-to u0 (map-get? deposits tx-sender)) amount))
    (ok true)
  )
)

;; Function 2: Return deposit (only landlord can release)
(define-public (return-deposit (renter principal) (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (is-eq tx-sender 'ST000000000000000000002AMW42H) err-not-owner)
    (let ((deposit (default-to u0 (map-get? deposits renter))))
      (asserts! (>= deposit amount) err-no-deposit)
      (try! (stx-transfer? amount (as-contract tx-sender) renter))
      (map-set deposits renter (- deposit amount))
      (ok true)
    )
  )
)
