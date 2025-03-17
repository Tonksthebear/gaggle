require "mcp/rails/railtie" if defined?(Rails)

namespace :gaggle do
  desc "Install Gaggle"
  task :install do
    Rails::Command.invoke :generate, [ "gaggle:install" ]
  end
end
