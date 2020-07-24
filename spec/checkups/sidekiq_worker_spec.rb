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

  RSpec.describe Checkups::SidekiqWorker do
    let(:worker) { described_class.new }

    context "daily" do
      it "queues the Daily checkups" do
        expect do
          described_class.perform_async("daily")
        end.to change(described_class.jobs, :size).by(1)
      end

      it "queues the one checkup worker" do
        expect do
          worker.perform("daily")
        end.to change(Checkups::OneCheckupWorker.jobs, :size).by(1)

        expect(Checkups::OneCheckupWorker.jobs.last["args"]).to eq(["TestWorkerCheckup", false])
      end
    end

    context "hourly" do
      it "queues the Hourly checkups" do
        expect do
          described_class.perform_async("hourly")
        end.to change(described_class.jobs, :size).by(1)
      end
    end
  end
end
