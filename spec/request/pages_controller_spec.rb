require "rails_helper"

RSpec.describe PagesController, type: :request do
  it "renders the about page without errors" do
    get "/about"
    expect(response).to be_successful
  end

  it "renders the stats page without errors" do
    get "/about/stats"
    expect(response).to be_successful
  end

  describe "GET /ok" do
    before do
      allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 1))
      allow(Sidekiq::Stats).to receive(:new).and_return(instance_double(Sidekiq::Stats, enqueued: 0))
      allow(Puma).to receive(:stats).and_return(JSON.dump("worker_status" => []))
    end

    it "returns 200 with an OK line per subsystem when healthy" do
      get "/ok"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("OK", "db", "sidekiq workers", "sidekiq queue", "puma")
    end

    it "returns 503 with FAIL line when sidekiq has no workers, while still reporting other subsystems" do
      allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 0))

      get "/ok"

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to include("FAIL sidekiq workers")
      expect(response.body).to include("OK  db")
    end

    it "returns 503 when sidekiq queue is over 50" do
      allow(Sidekiq::Stats).to receive(:new).and_return(instance_double(Sidekiq::Stats, enqueued: 51))

      get "/ok"

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to include("FAIL sidekiq queue: 51 (> 50)")
    end

    it "reports puma 'up' when Puma.stats returns the worker-local view" do
      allow(Puma).to receive(:stats).and_return(JSON.dump("pool_capacity" => 5, "backlog" => 0))

      get "/ok"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("OK  puma: up")
    end
  end
end
