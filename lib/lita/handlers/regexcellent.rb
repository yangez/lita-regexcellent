module Lita
  module Handlers
    class Regexcellent < Handler

      route(
        /^count\s+\/(.+)\/(.*)/i,
        :count,
        :command => true,
        :help    => {
          "count /REGEX/" => "Counts number of regex matches in channel"
        }
      )

      def count(response)
        regex_string = response.matches.first.first
        regex = Regexp.new regex_string

        options = {channel: response.room.id, count: 1000}

        puts '--- response matches ---'
        puts response.matches
        puts '--- end response matches ---'

        options_string = response.matches.last.last
        if options_string && options_string.length > 0
          to_string = options_string.match(/to:(\S+)/)
          to = Chronic.parse to_string.try(:captures).try(:first).try(:tr, "_", " ") if to_string
          options.merge!({oldest: 0, latest: to.utc.to_f}) if to

          from_string = options_string.match(/from:(\S+)/)
          from = Chronic.parse from_string.captures.first.tr("_", " ") if from_string
          options.merge!({oldest: from.utc.to_f}) if from
        end

        puts '--- options ---'
        puts options.inspect
        puts '--- end options ---'

        history = slack_client.channels_history(options)

        count = history.messages.count{ |message| message.text.match regex }
        response.reply("Found #{count} results.")
      end

      Lita.register_handler(self)

      protected

      def slack_client
        @slack_client ||= ::Slack::Web::Client.new
      end

    end
  end
end
