module Gaggle
  class Engine < ::Rails::Engine
    require "classy/yaml"
    isolate_namespace Gaggle

    config.to_prepare do
      Classy::Yaml.setup do |config|
        Gaggle::ApplicationController.helper(Classy::Yaml::Helpers)
        config.engine_files << Engine.root.join("config/utility_classes.yml")
      end
    end

    initializer "gaggle.development_check" do
      unless Rails.env.development? || Rails.env.test?
        warn "Gaggle is intended for development use only. It is not loaded in #{Rails.env} environment."
      end
    end

    initializer "gaggle.assets" do |app|
      if Gem.loaded_specs.key?("sprockets-rails")  # Check if sprockets-rails is in the host app
        # Sprockets setup
        Rails.logger.info "Gaggle: Detected sprockets-rails, configuring for Sprockets"
        app.config.assets.paths << Engine.root.join("app", "assets", "stylesheets")
        app.config.assets.precompile += %w[gaggle/tailwind.css]  # Adjust for your assets
      else
        # Propshaft setup
        Rails.logger.info "Gaggle: No sprockets-rails detected, configuring for Propshaft"
        app.config.paths.add Engine.root.join("app", "assets", "stylesheets")
      end
    end

    initializer "gaggle.importmap.assets", before: "importmap" do |app|
      javascript_path = Engine.root.join("app", "gaggle", "javascript")
      if Gem.loaded_specs.key?("sprockets-rails")
        app.config.assets.paths << javascript_path
      else
        app.config.paths.add javascript_path
      end
      if defined?(Importmap::Engine)
        app.config.importmap.paths << javascript_path
      end
    end

    initializer "gaggle.autoloader" do |app|
      Rails.autoloaders.main.ignore(Gaggle::Engine.root.join("app/models/gaggle/session.rb"))

      app.config.after_initialize do
        require Gaggle::Engine.root.join("app/models/gaggle/session.rb")
      end
    end
  end
end
