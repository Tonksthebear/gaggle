require_relative "lib/gaggle/version"

Gem::Specification.new do |spec|
  spec.name        = "gaggle"
  spec.version     = Gaggle::VERSION
  spec.authors     = [ "Tonksthebear" ]
  spec.email       = [ "jasonconig@me.com" ]
  spec.homepage    = "TODO"
  spec.summary     = "TODO: Summary of Gaggle."
  spec.description = "TODO: Description of Gaggle."
  spec.license     = "MIT"
  spec.add_dependency "solid_queue"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "tailwindcss-rails"
  spec.add_dependency "importmap-rails"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.0.beta1"
end
