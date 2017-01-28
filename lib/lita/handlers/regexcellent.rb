module Lita
  module Handlers
    class Regexcellent < Handler
      Lita.register_handler(self)

      DEFAULT_RANGE = {
        since: Chronic.parse("1 week ago").utc.to_f,
        until: Chronic.parse("10 minutes from now").utc.to_f,
      }

      route(
        /^count\s+\/(.+)\/(.*)/i,
        :count,
        :command => true,
        :help    => {
          "count /REGEX/ from:1_week_ago to:10_minutes_from_now" => "Counts number of regex matches in channel. 'from' and 'to' are optional (defaults shown)"
        }
      )

      def count(response)
        messages = fetch_slack_message_history(response)

        regex_string = response.matches.first.first
        regex = Regexp.new regex_string

        count = messages.count{ |message| message.text.match regex }
        response.reply("Found #{count} results.")
      end

      protected

      def fetch_slack_message_history(response)
        messages = []

        oldest = timestamp_for('from', response) || DEFAULT_RANGE[:since]
        latest = timestamp_for('to', response) || DEFAULT_RANGE[:until]

        loop do
          history = slack_client.channels_history({
            channel: response.room.id,
            count: 1000,
            inclusive: 0,
            oldest: oldest,
            latest: latest
          })
          messages.push(history.messages).flatten!

          if history.has_more
            latest = history.messages.last.ts
          else
            break
          end
        end
        messages
      end

      def timestamp_for(type, response)
        raise "unknown timestamp type" unless %w(to from).include? type
        options_string = response.matches.last.last
        return unless options_string && options_string.length > 0
        time_string = options_string.match(/#{type}:(\S+)/)
        time = Chronic.parse time_string.try(:captures).try(:first).try(:tr, "_", " ") if time_string
        time.utc.to_f if time
      end

      def slack_client
        @slack_client ||= ::Slack::Web::Client.new
      end

    end
  end
end
