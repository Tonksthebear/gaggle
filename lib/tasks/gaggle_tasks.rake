# lib/tasks/gaggle_tasks.rake

desc "Copy over the schema. Not for use by Goose."

namespace :gaggle do
  task :install do
    Rails::Command.invoke :generate, [ "gaggle:install" ]
  end

  task :update do
    Rails::Command.invoke :generate, [ "gaggle:update" ]
  end
end
