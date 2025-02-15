# Gaggle

Gaggle is a Rails engine designed for development use that orchestrates multiple instances of Goose. The name is a play on words inspired by the term for a group of geese, reflecting its role in managing and coordinating multiple instances of the underlying "Goose" service.

## Features

- Designed exclusively for development environments.
- Integrates with:
  - **SolidQueue** for background job processing.
  - **Turbo** (via turbo-rails) for accelerated page updates.
  - **Stimulus** (via stimulus-rails) for lightweight JavaScript interactions.
  - **TailwindCSS** (via tailwindcss-rails) for utility-first styling.
  - **Importmap** (via importmap-rails) for managing JavaScript dependencies without Node.js.

## Installation

Add this line to your application's Gemfile inside the development group:

```ruby
group :development do
  gem 'gaggle', path: 'path/to/your/local/gaggle'
end
```

Then execute:

```shell
bundle install
```

## Usage

Gaggle is intended for development use in Rails applications. When the engine is loaded in a non-development environment, it will emit a warning and not initialize its functions.

## Testing

Gaggle is set up with Minitest. To run the tests, execute:

```shell
bundle exec rake test
```

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

This project is licensed under the [MIT License](MIT-LICENSE).

## Extra Credit

For Cline users, this engine heavily leveraged Cline for the creation and management.