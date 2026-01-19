## Reference a module

You reference a module by prefixing by `module`, then the type.
To reference a module, you must declare its outputs.
When declaring modules, you must have declared output variables passed as input to the module declaration

# `depends_on`

`depends_on` on a module forces Terraform to treat that module as needing another
  resource/module to be created first, even if there’s no direct input/output reference.
  It’s a way to override implicit ordering.