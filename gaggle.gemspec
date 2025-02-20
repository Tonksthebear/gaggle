require_relative "lib/gaggle/version"

Gem::Specification.new do |spec|
  spec.name        = "gaggle"
  spec.version     = Gaggle::VERSION
  spec.authors     = [ "Tonksthebear" ]
  spec.homepage    = "https://github.com/Tonksthebear/gaggle"
  spec.summary     = "Gem providing core functionality for Gaggle."
  spec.description = "A gem that encapsulates the facilitation and use of multiple instances of the Goose instances when in development."
  spec.license     = "MIT"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "classy-yaml"
  spec.add_dependency "strings-ansi"
  spec.add_development_dependency "tailwindcss-rails"
  spec.add_development_dependency "importmap-rails"
  spec.add_development_dependency "stimulus-rails"
  spec.add_development_dependency "rubocop"


  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "https://example.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Tonksthebear/gaggle"
  spec.metadata["changelog_uri"] = "https://github.com/Tonksthebear/gaggle/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7"
end
