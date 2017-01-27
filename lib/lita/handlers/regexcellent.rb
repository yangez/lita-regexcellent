module Lita
  module Handlers
    class Regexcellent < Handler

      route(
        /^count\s+(.+)/i,
        :count,
        :command => true,
        :help    => {
          "count /REGEX/" => "Counts number of regex matches in channel"
        }
      )

      def count(response)
        name   = response.matches.first.first
        name   = "<#{name}>" if name.start_with?("@")
        message = "cool message"

        response.reply("#{name}, here's a #{message}")
      end

      Lita.register_handler(self)
    end
  end
end
