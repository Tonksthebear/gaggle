module Gaggle
  class Engine < ::Rails::Engine
    isolate_namespace Gaggle

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

    initializer "gaggle.importmap.assets" do
      Rails.application.config.assets.paths << Engine.root.join("app/javascript")
    end
  end
end
