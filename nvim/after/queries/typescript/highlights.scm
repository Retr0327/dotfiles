;; extends

(decorator
  "@" @function
  (identifier) @function)

(decorator
  "@" @function
  (call_expression
    (identifier) @function))

(decorator
  "@" @function
  (member_expression
    (property_identifier) @function))

(decorator
  "@" @function
  (call_expression
    (member_expression
      (property_identifier) @function)))
