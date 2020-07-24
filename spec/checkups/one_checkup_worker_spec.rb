# frozen_string_literal: true

if defined?(Sidekiq)
  require "spec_helper"
  require "sidekiq/testing"
  require "checkups/sidekiq_worker"
  require "checkups/checkup"

  class TestWorkerCheckup < Checkups::Checkup
    def self.frequency
      :daily
    end
  end

  RSpec.describe Checkups::OneCheckupWorker do
    let(:worker) { described_class.new }

    it "runs the given checkup" do
      TestWorkerCheckup.any_instance.expects(:check_and_notify!)

      worker.perform(TestWorkerCheckup.name, false)
    end
  end
end
