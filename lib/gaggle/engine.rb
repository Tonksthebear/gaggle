module Gaggle
  class Engine < ::Rails::Engine
    isolate_namespace Gaggle

    initializer "gaggle.development_check" do
      unless Rails.env.development? || Rails.env.test?
        warn "Gaggle is intended for development use only. It is not loaded in #{Rails.env} environment."
      end
    end
  end
end
