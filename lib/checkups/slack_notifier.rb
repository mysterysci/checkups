# frozen_string_literal: true

module Checkups
  class SlackNotifier
    def notify(checkup)
      attachments = build_attachments(checkup.status,
                                      checkup.notify_message,
                                      checkup.name,
                                      checkup.url)
      send_attachments(attachments)
    end

    def send_attachments(_attachments)
      raise "Must subclass Checkups::SlackNotifier#send_attachments"
    end

    # https://api.slack.com/docs/message-attachments#attachment_structure
    def build_attachments(status, message, title = nil, title_link = nil)
      attachment = {"color": status_to_slack_color(status),
                    "text": message}
      attachment[:title] = title if title
      attachment[:title_link] = title_link if title_link
      [attachment]
    end

    def status_to_slack_color(status)
      case status
      when :ok, :info
        "good"
      when :warning
        "warning"
      when :error, :fatal
        "danger"
      end
    end
  end
end
