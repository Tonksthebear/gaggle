# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

class Gaggle::UpdateGenerator < Rails::Generators::Base
  include ActiveRecord::Generators::Migration

  source_root File.expand_path("templates", __dir__)

  def copy_files
    # For reference
    # migration_template "db/migrate/create_compact_channel.rb",
    #                    "db/gaggle/create_compact_channel.rb"
  end
end
