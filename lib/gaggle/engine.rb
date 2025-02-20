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
      app.config.assets.precompile << Engine.root.join("app/assets/gaggle/builds/application.css")
    end

    initializer "gaggle.tailwindcss" do |app|
      app.config.assets.paths << Engine.root.join("app/assets/gaggle/builds/application.css")
    end

    initializer "gaggle.importmap", before: "importmap" do |app|
      app.config.importmap.paths << Engine.root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << Engine.root.join("app/gaggle/javascript")
    end

    initializer "gaggle.importmap.assets" do |app|
      app.config.assets.paths << Engine.root.join("app/javascript")
    end

    initializer "gaggle.autoloader" do |app|
      Rails.autoloaders.main.ignore(Gaggle::Engine.root.join("app/models/gaggle/session.rb"))

      app.config.after_initialize do
        require Gaggle::Engine.root.join("app/models/gaggle/session.rb")
      end
    end
  end
end
