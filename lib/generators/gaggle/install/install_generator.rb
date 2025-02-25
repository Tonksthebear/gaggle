class Gaggle::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def copy_files
    template "db/gaggle_schema.rb"
  end
end
