require "lita"
require "chronic"
require "slack-ruby-client"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/regexcellent"

Lita::Handlers::Regexcellent.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end
