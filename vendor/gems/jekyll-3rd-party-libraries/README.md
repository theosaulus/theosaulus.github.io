# jekyll-3rd-party-libraries (vendored, patched)

This is a **local, vendored copy** of the upstream gem
[`jekyll-3rd-party-libraries` v0.0.1](https://github.com/george-gca/jekyll-3rd-party-libraries)
by George Corrêa de Araújo (MIT licensed). It is pulled in via a `path:` entry in the
project `Gemfile`.

## Why it is vendored

The gem is a transitive dependency of `al_img_tools` (`~> 0.0.1`), and its published
`0.0.1` gemspec pins `css_parser` to `>= 1.6, < 2.0`. That upper bound forces the
vulnerable `css_parser` 1.x line and makes it impossible for Bundler to resolve the
patched `css_parser >= 3.0.0`, which fixes the SSRF / local-file-disclosure advisory in
`CssParser::Parser#read_remote_file` (`load_uri!` / `add_block!` with `base_uri:`).

Upstream has published only `0.0.1`, so there is no released version with a relaxed
constraint to upgrade to.

## What was changed

- **`jekyll-3rd-party-libraries.gemspec`** — the only functional change: the `css_parser`
  requirement is relaxed from `>= 1.6, < 2.0` to `>= 1.6` so Bundler can select
  `css_parser >= 3.0.0`. The `jekyll` and `nokogiri` constraints are unchanged.
- **`lib/**`** — byte-for-byte identical to the published `0.0.1` gem
  (`lib/jekyll-3rd-party-libraries.rb`, `lib/jekyll-3rd-party-libraries/version.rb`).

## Why the css_parser upgrade is safe here

This plugin's only use of css_parser is, in `download_fonts_from_css`:

```ruby
css = CssParser::Parser.new
css.load_string! doc.document.text   # CSS already downloaded by this plugin, not by css_parser
css.each_rule_set { |rule_set| ... }
File.write(dest, css.to_s)
```

It never calls the vulnerable entry points (`load_uri!`, `read_remote_file`, or
`add_block!` with a `base_uri:` that triggers `@import` following). Those APIs are
unchanged and only hardened in css_parser 3.x, so this usage is fully API-compatible.

If/when upstream releases a version allowing `css_parser >= 3`, remove this directory and
restore the plain `gem "jekyll-3rd-party-libraries"` line in the `Gemfile`.
