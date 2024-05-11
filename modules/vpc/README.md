# vpc module

<!-- TFDOCS START -->
```
module <vpc> {
  source = "git@github.com:blitspersecond/infra.git//modules/vpc?ref=<TAG>"
  availability_zones = <MAP(STRING)>    # No description provided
  cidr_block = <STRING>                 # No description provided
  environment = <STRING>                # No description provided
  fck_nat = <BOOL>                      # No description provided
  tags = <MAP(STRING)>                  # No description provided
  vpc_name = <STRING>                   # No description provided
}
```
<!-- TFDOCS END -->
