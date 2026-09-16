# BASIC# Small Compiler Subset Execution Corpus v0.0.67

v0.0.67 carries forward the v0.0.66 BSBC execution corpus while adding plain-English movement intent coverage outside the self-hosting fixture corpus.

The execution corpus remains sealed at 17 fixtures across 17 categories with 55 event executions. The new movement-intent proof lives in the production parser/resolver/runtime input lane and is validated by `tools/plain_english_movement_intent.rb` plus `tests/test_plain_english_movement_intent.rb`.

Ruby remains the bootstrap compiler and referee runtime.
