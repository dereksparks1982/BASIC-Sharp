# BASIC# Validation v0.0.71

Required validation for this build:

```bash
LC_ALL= LANG= RUBYOPT= ruby -Itests tests/test_cli_output.rb
LC_ALL= LANG= RUBYOPT= ruby -Itests -e 'Dir["tests/test_*.rb"].sort.each { |f| require_relative f }'
ruby -Itests -e 'Dir["tests/test_*.rb"].sort.each { |f| require_relative f }'
ruby tools/utf8_source_reading_contract.rb
ruby tools/readme_current_release_truth.rb
ruby tools/self_hosting_contract.rb
ruby tools/trial_by_fire_inventory.rb
ruby tools/release_forensic_overlay.rb
ruby tools/release_package_preflight.rb
ruby tools/trial_by_fire_gauntlet.rb
```

Expected test suite result: 577 runs, 9290 assertions, 0 failures, 0 errors, 0 skips.
