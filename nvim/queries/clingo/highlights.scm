; extends
;; Recapture %*! doc blocks as @comment.documentation so they read as
;; documentation rather than plain comments. Upstream query captures
;; doc_comment as @comment and the predicate name inside as @function.
;; Priority 200 beats the default (100) so the whole block — including
;; the signature line — renders as documentation.
((doc_comment) @comment.documentation
  (#set! "priority" 300))
