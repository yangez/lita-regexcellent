module Lita
  module Handlers
    class Regexcellent < Handler
      Lita.register_handler(self)
      class InvalidTimeFormatError < StandardError; end

      DEFAULT_RANGE = {
        since: "1 week ago",
        until: "now"
      }
      MESSAGES = {
        found: "Found %{count} results for `/%{regex_string}/` since *%{oldest}* until *%{latest}*.",
        invalid_time_format: "Couldn't understand `since:%{oldest} until:%{latest}`."
      }

      route(
        /^count\s+(\S+)(.*)/i,
        :count,
        :command => true,
        :help    => {
          "count REGEX since:1_week_ago until:now" => "Counts number of regex matches in channel. 'since' and 'until' are optional (defaults shown)"
        }
      )

      def count(response)
        data = {
          oldest: time_string_for('since', response) || DEFAULT_RANGE[:since],
          latest: time_string_for('until', response) || DEFAULT_RANGE[:until],
          regex_string: response.matches.first.first.tr('/', '')
        }

        begin
          messages = fetch_slack_message_history(response.room.id, data[:oldest], data[:latest])
          regex = Regexp.new data[:regex_string]
          reply = MESSAGES[:found] % data.merge({
            count: count_messages(messages, regex)
          })
        rescue InvalidTimeFormatError
          reply = MESSAGES[:invalid_time_format] % {
            oldest: data[:oldest].tr(" ", "_"),
            latest: data[:latest].tr(" ", "_")
          }
        end
        response.reply(reply)
      end

      protected

      def fetch_slack_message_history(room_id, oldest, latest)
        messages = []

        loop do
          options = {
            channel: room_id,
            count: 1000,
            inclusive: 0,
            oldest: string_to_timestamp(oldest),
            latest: string_to_timestamp(latest)
          }
          history = slack_client.channels_history(options)
          messages.push(history.messages).flatten!

          if history.has_more
            latest = history.messages.last.ts
          else
            break
          end
        end
        messages
      end

      def count_messages(messages, regex)
        messages.count do |message|
          next if message.user == robot_user_id # skip messages from self
          next if message.text.match(/^@?#{robot.mention_name}\scount.*/i) # skip `bot count` queries
          message.text.match regex
        end
      end

      def time_string_for(type, response)
        raise "unknown time string type" unless %w(since until).include? type
        options_string = response.matches.last.last
        return unless options_string && options_string.length > 0
        time_string = options_string.match(/#{type}:(\S+)/)
        time_string.captures.first.try(:tr, "_", " ") if time_string
      end

      def string_to_timestamp(time_string)
        parsed_string = Chronic.parse(time_string)
        fail InvalidTimeFormatError unless parsed_string

        # slack API can only handle 6 digits, otherwise it bugs out
        sprintf("%0.06f", parsed_string.utc.to_f)
      end

      # couldn't find a direct way to get robot user id (e.g. robot.user_id)
      # so instead we use the method that `lita users find [name]` uses:
      # https://github.com/litaio/lita-default-handlers/blob/master/lib/lita/handlers/users.rb
      def robot_user_id
        robot_id = User.fuzzy_find(robot.mention_name).id
      end

      def slack_client
        @slack_client ||= ::Slack::Web::Client.new
      end

    end
  end
end
