# Used by "mix format"
[
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  excludes: [
    # Skip formatter validation for the parser, since 'abnf_parsec'
    # injects a great deal of macros and proper formatting isn't really a concern.
    "lib/parser.ex"
  ]
]
