require 'rails_helper'

RSpec.describe CreateAudioFeatureJob, type: :job do
  subject(:job) { described_class.perform_later(assets(:valid_arthur_mp3).id) }

  it "queues the job" do
    expect { job }.to have_enqueued_job(described_class)
      .with(assets(:valid_arthur_mp3).id)
      .on_queue("default")
  end
end
