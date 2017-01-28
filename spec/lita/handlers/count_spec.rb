require "spec_helper"

RSpec.describe Lita::Handlers::Regexcellent, :lita_handler => true do
  let(:robot) { Lita::Robot.new(registry) }


  subject { described_class.new(robot) }

  describe "#count" do
    before do
      allow_any_instance_of(described_class).to receive(:fetch_slack_message_history).and_return([])
    end

    it { is_expected.to route("Lita count /regex/") }
    it { is_expected.to route("Lita count /regex/ from:yesterday to:today") }

    it "responds with a count" do
      send_message("Lita count /regex/")
      expect(replies.last).to eq "Found 0 results."
    end
  end

  describe "#fetch_slack_message_history" do
    it "will be tested"
  end
end
