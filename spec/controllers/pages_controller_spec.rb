require "rails_helper"

RSpec.describe PagesController, type: :controller do
  it "should have an about page that renders without errors" do
    get :about
    expect(response).to be_successful
  end

  it "should have a stats page that renders without errors" do
    get :stats
    expect(response).to be_successful
  end

  describe "GET health (mounted at /ok)" do
    before do
      allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, empty?: false))
      allow(Sidekiq::Stats).to receive(:new).and_return(instance_double(Sidekiq::Stats, enqueued: 0))
      allow(Puma).to receive(:stats).and_return(JSON.dump("worker_status" => []))
    end

    it "returns 200 with an OK line per subsystem when healthy" do
      get :health
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("OK", "db", "sidekiq workers", "sidekiq queue", "puma")
    end

    it "returns 503 with FAIL line when sidekiq has no workers, while still reporting other subsystems" do
      allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, empty?: true))

      get :health
      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to include("FAIL sidekiq workers")
      expect(response.body).to include("OK  db")
    end

    it "returns 503 when sidekiq queue is over 50" do
      allow(Sidekiq::Stats).to receive(:new).and_return(instance_double(Sidekiq::Stats, enqueued: 51))

      get :health
      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to include("FAIL sidekiq queue: 51 (> 50)")
    end

    it "reports puma 'up' when Puma.stats returns the worker-local view (no worker_status key)" do
      allow(Puma).to receive(:stats).and_return(JSON.dump("pool_capacity" => 5, "backlog" => 0))

      get :health
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("OK  puma: up")
    end
  end
end
