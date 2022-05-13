# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

begin
  require "annotate"
  Annotate.set_defaults(
    position_in_class: :after,
    position_in_serializer: :after,
    exclude_tests: true,
    exclude_fixtures: true
  )
  Annotate.load_tasks
rescue LoadError
end

Rails.application.load_tasks

