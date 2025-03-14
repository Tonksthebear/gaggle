# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [ File.expand_path("fixtures", __dir__) ]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end


class ActionDispatch::IntegrationTest
  # Helper to access the engine's mounted namespace
  def gaggle
    Gaggle::Engine.routes.url_helpers
  end

  # Define a method to wrap tests with engine routes
  def with_engine_routes(&block)
    original_routes = nil
    begin
      # Set routes before the test runs, if controller is available
      if @controller && @controller.view_context
        original_routes = @controller.view_context.routes
        @controller.view_context.instance_variable_set(:@_routes, Gaggle::Engine.routes)
      end
      block.call
    ensure
      # Restore routes after the test, if they were changed
      if @controller && @controller.view_context && original_routes
        @controller.view_context.instance_variable_set(:@_routes, original_routes)
      end
    end
  end

  # Override the run method to apply engine routes to all tests
  def run(*args)
    with_engine_routes { super(*args) }
  end
end
