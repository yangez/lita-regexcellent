module Lita
  module Handlers
    class Regexcellent < Handler
      Lita.register_handler(self)

      route(
        /^count\s+\/(.+)\/(.*)/i,
        :count,
        :command => true,
        :help    => {
          "count /REGEX/ from:1_year_ago to:yesterday" => "Counts number of regex matches in channel. 'from' and 'to' are optional"
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
        oldest = timestamp_for('from', response)
        latest = timestamp_for('to', response)

        loop do
          options = {channel: response.room.id, count: 100, inclusive: 0}
          options.merge!({oldest: oldest}) if oldest
          options.merge!({latest: latest}) if latest

          history = slack_client.channels_history( options )
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
