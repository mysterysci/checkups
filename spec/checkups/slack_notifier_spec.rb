# frozen_string_literal: true

require "spec_helper"

require_relative "checkup_fixtures"

RSpec.describe Checkups::SlackNotifier do
  context "attachments" do
    it "converts status to slack color" do
      expect(subject.status_to_slack_color(:ok)).to eq "good"
      expect(subject.status_to_slack_color(:info)).to eq "good"
      expect(subject.status_to_slack_color(:warning)).to eq "warning"
      expect(subject.status_to_slack_color(:error)).to eq "danger"
      expect(subject.status_to_slack_color(:fatal)).to eq "danger"
    end

    it "puts color into the attachment" do
      attachments = subject.build_attachments(:ok, "")
      expect(attachments.first).to include(color: "good")
    end

    it "puts message into the attachment" do
      attachments = subject.build_attachments(:ok, "hey")
      expect(attachments.first).to include(text: "hey")
    end

    it "puts excludes title and title link if not set" do
      attachments = subject.build_attachments(:ok, "hey")
      expect(attachments.first.keys).to_not include(:title, :title_link)
    end

    it "puts title into attachment" do
      attachments = subject.build_attachments(:ok, "hey", "My Checkup")
      expect(attachments.first).to include(title: "My Checkup")
    end

    it "puts title_link into attachment" do
      attachments = subject.build_attachments(:ok, "hey", nil, "http://example.com")
      expect(attachments.first).to include(title_link: "http://example.com")
    end

    it "converts values from checkup to attachment" do
      notifier = Checkups::SlackNotifier.new

      def notifier.send_attachments(attachments)
        @attachments = attachments
      end

      checkup = TestCheckup.new(:warning, "woah guys!", "api", "http://api.com")
      attachments = notifier.notify(checkup)
      expected_hash = {
        text: "Checkup Warning: woah guys!",
        color: "warning",
        title: "api",
        title_link: "http://api.com"
      }
      expect(attachments.first).to include(expected_hash)
    end
  end
end
