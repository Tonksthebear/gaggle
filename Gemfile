source "https://rubygems.org"

# Specify your gem's dependencies in gaggle.gemspec
gemspec

gem "puma"
gem "sqlite3"

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem "rubocop-rails-omakase", require: false

gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "classy-yaml"
gem "jbuilder"
gem "strings-ansi"
gem "mcp-rails", git: "https://github.com/Tonksthebear/mcp-rails"

group :development do
  gem "web-console"
  gem "tailwindcss-ruby"
  gem "hotwire-spark"
  gem "erb_lint"
  gem "erb-formatter"
end

group :test do
  gem "mocha"
end

# Appraisal gem for testing multiple Rails versions
gem "appraisal"
