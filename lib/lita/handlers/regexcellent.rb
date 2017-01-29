module Lita
  module Handlers
    class Regexcellent < Handler
      Lita.register_handler(self)
      class InvalidTimeFormatError < StandardError; end

      DEFAULT_RANGE = {
        since: "1 week ago",
        until: "now"
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
        oldest = time_string_for('since', response) || DEFAULT_RANGE[:since]
        latest = time_string_for('until', response) || DEFAULT_RANGE[:until]

        regex_string = response.matches.first.first.tr('/', '')
        regex = Regexp.new regex_string

        begin
          messages = fetch_slack_message_history(response.room.id, oldest, latest)
          count = messages.count{ |message| message.text.match regex }
          response.reply("Found #{count} results for */#{regex_string}/* since *#{oldest}* until *#{latest}*.")
        rescue InvalidTimeFormatError
          response.reply("Couldn't understand `since:#{oldest.tr(" ", "_")} until:#{latest.tr(" ", "_")}`.")
        end
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

      def slack_client
        @slack_client ||= ::Slack::Web::Client.new
      end

    end
  end
end
