require "spec_helper"

RSpec.describe Lita::Handlers::Regexcellent, :lita_handler => true do
  let(:robot) { Lita::Robot.new(registry) }

  let(:robot_id) { "STUBBED_ID" }
  let(:message_stub) { Struct.new(:text, :user) }

  subject { described_class.new(robot) }

  describe "#count" do
    let(:room) { double(Lita::Room, id: 1)}
    let(:messages) { [] }


    before do
      allow_any_instance_of(described_class).to receive(:fetch_slack_message_history).and_return(messages)
      allow_any_instance_of(Lita::Response).to receive(:room).and_return(room)
      allow_any_instance_of(described_class).to receive(:robot_user_id).and_return(robot_id)
    end

    it { is_expected.to route("@lita count regex") }
    it { is_expected.to route("lita count regex") }
    it { is_expected.to route("lita count regex since:yesterday until:today") }

    it "responds with a count" do
      send_message("Lita count regex")
      expect(replies.last).to match /Found 0 results for `\/regex\/` since \*1 week ago\* until \*now\*\./
    end

    context "when there are messages from itself" do
      let(:self_message) { message_stub.new("hi world", robot_id) }
      let(:valid_message) { message_stub.new("hi world", "REGULAR_USER_ID") }
      let(:messages) { [self_message, valid_message] }

      it "does not count self messages" do
        send_message("Lita count world")
        expect(replies.last).to match /^Found 1 result.*/
      end
    end

    context "when there are existing messages querying the bot" do
      let(:query_message) { message_stub.new("lita count so cool", "REGULAR_USER_ID") }
      let(:query_message2) { message_stub.new("@lita count so cool", "REGULAR_USER_ID") }
      let(:valid_message) { message_stub.new("so cool indeed", "REGULAR_USER_ID") }
      let(:messages) { [query_message, query_message2, valid_message] }

      it "does not count querying messages" do
        send_message("Lita count cool")
        expect(replies.last).to match /^Found 1 result.*/
      end
    end

    context "when regex is formatted as /regex/" do
      it "responds with a count" do
        send_message("lita count /regex/")
        expect(replies.last).to match /Found 0 results for `\/regex\/` since \*1 week ago\* until \*now\*\./
      end
    end
  end

  describe "#fetch_slack_message_history" do
    it "will be tested"
  end
end
