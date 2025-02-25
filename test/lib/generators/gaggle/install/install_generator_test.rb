require "test_helper"
require_relative "../../../../../lib/generators/gaggle/install/install_generator"

class Gaggle::InstallGeneratorTest < Rails::Generators::TestCase
  tests Gaggle::InstallGenerator
  destination File.expand_path("../../../../../tmp", __dir__)

  setup :prepare_destination
  setup :run_generator

  test "gaggle_schema exists" do
    assert_file "db/gaggle_schema.rb"
  end
end
