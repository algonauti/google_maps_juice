# Upgrade Plan: Ruby 4.0 + Dependencies

Target: Ruby >= 3.2.0 (compatible with 3.2, 3.3, 3.4, and 4.0)

---

## Current state

| Component | Current | Target |
|---|---|---|
| Ruby | 3.0.7 | 4.0.4 (min: 3.2.0) |
| Bundler | 2.2.33 | 4.0.x (ships with Ruby 4.0) |
| activesupport | 7.1.6 | 8.1.3 |
| excon | 1.2.5 | 1.4.2 |
| simplecov | 0.22.0 | 0.22.0 (already latest) |
| vcr | 6.4.0 | 6.4.0 (already latest) |
| rspec | 3.13.2 | 3.x latest |
| webmock | 3.26.2 | 3.x latest |
| rake | 13.4.2 | 13.x latest |
| dotenv | 3.2.0 | 3.x latest |

---

## Challenges identified

### Blocker 1 — Ruby version must be upgraded

The system runs Ruby 3.0.7. Ruby 4.0.4 must be installed before any
dependency upgrade can happen. The project uses mise with `.tool-versions`
for version pinning (already updated to `ruby 4.0.4`); run `mise install`
to pull the new version.

### Blocker 2 — activesupport 8.x requires Ruby >= 3.2.0

The currently-installed Ruby (3.0.7) cannot install AS 8.x at all.
Ruby must be upgraded **first**.

### Blocker 3 — `coveralls` missing from Gemfile

`spec/spec_helper.rb:1` does `require 'coveralls'`, but `coveralls` is
not listed in the Gemfile and is not installed locally. This is a
pre-existing broken state that must be fixed before the test suite can
run cleanly. The fix is to remove the `coveralls` wiring and use
`simplecov` directly (already in the Gemfile with `require: false`).

### Issue 4 — Bundler jump: 2.2.33 → 4.0.x

Ruby 4.0 ships with Bundler 4.0.x. Key breaking changes in Bundler 4:

- Lockfile gains a `CHECKSUMS` section by default on first regeneration
- Ruby version format in lockfile changes (patch level dropped)
- Several deprecated `bundle install` flags removed (`--deployment`,
  `--path`, `--without`, etc.)
- `Bundler.clean_env` / `with_clean_env` removed (use `unbundled_env`)
- `bundle viz` extracted to the `bundler-graph` plugin
- `bundle inject` replaced by `bundle add`

The lockfile must be **deleted and regenerated** under Bundler 4.

### Issue 5 — Deprecated `git_source(:github)` in Gemfile

`Gemfile:3` defines `git_source(:github)` — a long-deprecated Bundler
feature not used by any gem in this file. Remove it to avoid warnings
or breakage with Bundler 4.

### Deprecation warning 6 — `ActiveSupport::Configurable`

`lib/google_maps_juice/configuration.rb` does
`include ActiveSupport::Configurable`. AS 8.1.0 deprecated this module.
It still works in 8.1.x but **will be removed in AS 9.0**. Replace it
with a plain Ruby configuration object now to future-proof the library.

### Low-risk — Ruby 4.0 language changes

The library code is largely safe. Notable Ruby 4.0 changes:

- `*nil` no longer calls `nil.to_a` (raises `TypeError`) — not used
  explicitly in this codebase, but worth confirming via test run
- IO/Kernel process creation with leading `|` removed — not used here
- `Process::Status#&` and `#>>` removed — not used here
- `Ractor::Port` API changes — not used here

AS 8.1.3 is tested against Ruby 4.0 so any internal AS reliance on old
`*nil` behavior is already patched.

### Low-risk — excon 1.2.5 → 1.4.2

Two minor version bumps, no expected breaking changes. Requires
Ruby >= 3.1.0, so compatible with our >= 3.2.0 floor.

### No action needed

`simplecov`, `vcr`, `rspec`, `webmock`, `rake`, and `dotenv` are
already at their latest versions within their pinned ranges and are all
compatible with Ruby 3.2–4.0.

---

## Incremental plan

### Phase 1 — Fix pre-existing issues (on current Ruby, before any upgrade)

1. **`spec/spec_helper.rb`**: Remove the `require 'coveralls'` and
   `Coveralls.wear!` lines. Configure SimpleCov directly instead, e.g.:

   ```ruby
   require 'simplecov'
   SimpleCov.start if ENV['CI']
   ```

2. **`Gemfile`**: Remove the unused `git_source(:github)` block
   (lines 3–5).

These changes can be committed and CI can be verified on the current
Ruby version before touching anything else.

---

### Phase 2 — Install Ruby 4.0.4

The project uses [mise](https://mise.jdx.dev/) with `.tool-versions`
for version pinning — no `.ruby-version` file needed.

Update `.tool-versions` (already done):

```
ruby 4.0.4
```

Then install and activate:

```sh
mise install       # installs ruby 4.0.4 as declared in .tool-versions
mise use ruby@4.0.4  # activates it for the project
```

Verify:

```sh
ruby --version     # => ruby 4.0.4 ...
gem --version      # should be 4.x
bundler --version  # should be 4.x
```

---

### Phase 3 — Update gemspec

In `google_maps_juice.gemspec`:

1. Add a `required_ruby_version` constraint:

   ```ruby
   spec.required_ruby_version = '>= 3.2.0'
   ```

2. No changes needed to `add_dependency` lines — both `activesupport`
   and `excon` are unconstrained and Bundler will resolve the latest
   versions compatible with Ruby 4.0.

---

### Phase 4 — Regenerate lockfile

```sh
rm Gemfile.lock
bundle install
```

Bundler 4.x will resolve and lock:

- `activesupport 8.1.3` (and its updated transitive deps)
- `excon 1.4.2`
- Latest patch versions of rspec, webmock, rake, dotenv, vcr

Commit the new `Gemfile.lock`.

---

### Phase 5 — Fix `ActiveSupport::Configurable` deprecation

Replace `lib/google_maps_juice/configuration.rb` to avoid the
deprecated `ActiveSupport::Configurable`. A plain Ruby approach:

```ruby
module GoogleMapsJuice
  class Configuration
    attr_accessor :api_key

    def initialize
      @api_key = nil
    end
  end

  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end
  end
end
```

Update `lib/google_maps_juice.rb` accordingly: replace
`require 'active_support/configurable'` and the `include` with the
new config approach.

This eliminates the deprecation warning and removes the AS dependency
for configuration entirely.

---

### Phase 6 — Run tests and fix any failures

```sh
bundle exec rspec
```

Watch for:

- Any `TypeError` from `*nil` splat patterns surfaced by Ruby 4.0
- Any AS 8.x deprecation warnings not yet addressed
- Any behavior changes from the `HashWithIndifferentAccess#stringify_keys`
  fix in AS 8.0 (now stringifies all key types, not just symbols)

Fix failures as they arise. The expectation is that the test suite
passes cleanly given the simplicity of the library.

---

### Phase 7 (optional) — Add CI matrix

To validate backcompat across all supported Ruby versions, update the
CI workflow (e.g., GitHub Actions) to test against:

```yaml
strategy:
  matrix:
    ruby-version: ['3.2', '3.3', '3.4', '4.0']
```

---

## Notes

- Ruby 3.0 and 3.1 are already EOL and are intentionally excluded.
- Ruby 3.2 is the practical floor because it is the minimum required
  by `activesupport` 8.x, covering all currently-maintained 3.x
  releases (3.2, 3.3, 3.4) and Ruby 4.0 with a single dependency set.
- `simplecov` 0.22.0 is the latest release (December 2022). It declares
  `required_ruby_version >= 2.5.0` with no upper bound, so Ruby 4.0
  compatibility is not guaranteed by the gem spec — verify it works
  during Phase 6.
