require "spec_helper"

RSpec.describe Lita::Handlers::Regexcellent, :lita_handler => true do
  let(:robot) { Lita::Robot.new(registry) }


  subject { described_class.new(robot) }

  describe "#count" do
    let(:room) { double(Lita::Room, id: 1)}
    before do
      allow_any_instance_of(described_class).to receive(:fetch_slack_message_history).and_return([])
      allow_any_instance_of(Lita::Response).to receive(:room).and_return(room)
    end

    it { is_expected.to route("Lita count regex") }
    it { is_expected.to route("Lita count regex since:yesterday until:today") }

    it "responds with a count" do
      send_message("Lita count regex")
      expect(replies.last).to match /Found 0 results for \*\/regex\/\* since \*1 week ago\* until \*now\*\./
    end

    context "when regex is formatted as /regex/" do
      it "responds with a count" do
        send_message("Lita count /regex/")
        expect(replies.last).to match /Found 0 results for \*\/regex\/\* since \*1 week ago\* until \*now\*\./
      end
    end
  end

  describe "#fetch_slack_message_history" do
    it "will be tested"
  end
end
