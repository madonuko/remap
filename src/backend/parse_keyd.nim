include keyd_parser/header

assert parse(
  """
[ids]

*

[main]
a = b
"""
).res.ok
