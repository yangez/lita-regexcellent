require "spec_helper"

RSpec.describe Lita::Handlers::Regexcellent, :lita_handler => true do
  let(:robot) { Lita::Robot.new(registry) }

  subject { described_class.new(robot) }

  describe "#count" do
    # it { is_expected.to route("Lita count /regex/") }

    # it "responds with a count" do
    #   send_message("Lita count /regex/")
    #   expect(replies.last).to match(/(\w+\s) results found\./)
    # end
  end
end
