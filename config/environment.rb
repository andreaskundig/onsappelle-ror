# Load the Rails application.
require_relative "application"

app_env_vars = File.join(Rails.root, 'config', 'initializers', 'app_env_vars.rb')
load(app_env_vars) if File.exist?(app_env_vars)

# Initialize the Rails application.
Rails.application.initialize!
