# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "favicon_gem"
  spec.version = "0.1.0"
  spec.authors = ["Ivan Nemytchenko"]
  spec.email = ["nemytchenko@gmail.com"]

  spec.summary = "Ruby gem to find a website's favicon"
  spec.description = "favicon_gem is a Ruby library to find a website's favicon, ported from Python's favicon library"
  spec.homepage = "https://github.com/inem/favicon"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["lib/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "nokogiri", "~> 1.14"
  spec.add_dependency "faraday", "~> 2.7"
  spec.add_dependency "faraday-follow_redirects", "~> 0.3"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "rubocop", "~> 1.50"
end
