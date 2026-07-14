# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll-3rd-party-libraries/version"

Gem::Specification.new do |spec|
  spec.name        = "jekyll-3rd-party-libraries"
  spec.version     = Jekyll::ThirdPartyLibraries::VERSION
  spec.authors     = ["George Corrêa de Araújo"]
  spec.summary     = "Force updating cached files and resources in a Jekyll site."
  spec.description = "Force updating cached files and resources in a Jekyll site by adding a hash."
  spec.homepage    = "https://github.com/george-gca/jekyll-3rd-party-libraries"
  spec.license     = "MIT"

  spec.metadata["source_code_uri"] = "https://github.com/george-gca/jekyll-3rd-party-libraries"
  spec.metadata["bug_tracker_uri"] = "https://github.com/george-gca/jekyll-3rd-party-libraries/issues"
  spec.metadata["changelog_uri"]   = "https://github.com/george-gca/jekyll-3rd-party-libraries/releases"

  spec.files = [
    "lib/jekyll-3rd-party-libraries.rb",
    "lib/jekyll-3rd-party-libraries/version.rb",
    "LICENSE",
    "README.md",
  ]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_dependency "jekyll", ">= 3.6", "< 5.0"
  # Upstream 0.0.1 pins css_parser "< 2.0". That cap is relaxed here ONLY to permit the
  # non-vulnerable css_parser >= 3.0.0 (fixes GHSA css_parser SSRF/LFI in read_remote_file /
  # load_uri! / add_block! with base_uri). This plugin only calls CssParser::Parser#new,
  # #load_string!, #each_rule_set and #to_s on CSS it has already downloaded itself -- it never
  # calls the vulnerable remote-fetch entry points -- so css_parser 3.x is API-compatible here.
  # See README.md for details.
  spec.add_dependency "css_parser", ">= 1.6"
  spec.add_dependency "nokogiri", ">= 1.8", "< 2.0"
end
