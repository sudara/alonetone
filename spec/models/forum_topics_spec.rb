require 'rails_helper'

RSpec.describe ForumTopics do
  let(:json) do
    {
      'users' => [
        { 'id' => 1, 'username' => 'sudara' },
        { 'id' => 2, 'username' => 'marieh' }
      ],
      'topic_list' => {
        'topics' => [
          { 'id' => 99, 'slug' => 'rules', 'title' => 'Rules', 'pinned' => true,
            'posters' => [{ 'user_id' => 1, 'description' => 'Original Poster' }] },
          { 'id' => 8, 'slug' => 'welcome', 'title' => 'Welcome to the forum', 'pinned' => false,
            'posters' => [{ 'user_id' => 1, 'description' => 'Original Poster, Most Recent Poster' }] },
          { 'id' => 12, 'slug' => 'first-track', 'title' => 'Share your first track', 'pinned' => false,
            'posters' => [{ 'user_id' => 2, 'description' => 'Original Poster' }] }
        ]
      }
    }
  end

  describe '.parse' do
    it 'skips pinned topics' do
      topics = described_class.parse(json, 10)
      expect(topics.map(&:title)).to eq(['Welcome to the forum', 'Share your first track'])
    end

    it 'honors the limit' do
      expect(described_class.parse(json, 1).size).to eq(1)
    end

    it 'builds the topic url from slug and id' do
      topic = described_class.parse(json, 10).first
      expect(topic.url).to eq('https://forum.alonetone.com/t/welcome/8')
    end

    it 'resolves the original poster to author and profile url' do
      topic = described_class.parse(json, 10).last
      expect(topic.author).to eq('marieh')
      expect(topic.author_url).to eq('https://forum.alonetone.com/u/marieh')
    end

    it 'leaves author nil when the poster is unknown' do
      json['topic_list']['topics'][1]['posters'] = []
      topic = described_class.parse(json, 10).first
      expect(topic.author).to be_nil
      expect(topic.author_url).to be_nil
    end

    it 'falls back to the first poster when none is flagged as the original' do
      json['topic_list']['topics'][1]['posters'] = [{ 'user_id' => 2, 'description' => 'Most Recent Poster' }]
      expect(described_class.parse(json, 10).first.author).to eq('marieh')
    end

    it 'leaves author nil when the poster references an unknown user' do
      json['topic_list']['topics'][1]['posters'] = [{ 'user_id' => 999, 'description' => 'Original Poster' }]
      expect(described_class.parse(json, 10).first.author).to be_nil
    end

    it 'returns an empty array when topic_list is missing' do
      expect(described_class.parse({}, 10)).to eq([])
    end
  end

  describe '.fetch' do
    it 'returns parsed topics on success' do
      stub_request(:get, 'https://forum.alonetone.com/latest.json')
        .to_return(status: 200, body: json.to_json, headers: { 'Content-Type' => 'application/json' })
      expect(described_class.fetch(4).map(&:title)).to eq(['Welcome to the forum', 'Share your first track'])
    end

    it 'returns an empty array on a non-success response' do
      stub_request(:get, 'https://forum.alonetone.com/latest.json').to_return(status: 503)
      expect(described_class.fetch(4)).to eq([])
    end
  end

  context 'with a real cache store' do
    around do |example|
      original = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      example.run
      Rails.cache = original
    end

    describe '.refresh!' do
      it 'writes fetched topics and a timestamp to the cache' do
        stub_request(:get, 'https://forum.alonetone.com/latest.json')
          .to_return(status: 200, body: json.to_json, headers: { 'Content-Type' => 'application/json' })
        described_class.refresh!
        entry = Rails.cache.read(described_class::CACHE_KEY)
        expect(entry[:topics].map(&:title)).to eq(['Welcome to the forum', 'Share your first track'])
        expect(entry[:fetched_at]).to be_within(5.seconds).of(Time.current)
      end

      it 'does not overwrite the cache when the fetch fails' do
        stub_request(:get, 'https://forum.alonetone.com/latest.json').to_return(status: 503)
        described_class.refresh!
        expect(Rails.cache.read(described_class::CACHE_KEY)).to be_nil
      end

      it 'swallows and logs network errors' do
        stub_request(:get, 'https://forum.alonetone.com/latest.json').to_timeout
        expect(Rails.logger).to receive(:warn).with(/ForumTopics refresh failed/)
        expect { described_class.refresh! }.not_to raise_error
      end
    end

    describe '.latest' do
      let(:topics) { described_class.parse(json, 4) }

      def cache_entry(fetched_at:)
        Rails.cache.write(described_class::CACHE_KEY, { topics: topics, fetched_at: fetched_at })
      end

      it 'returns an empty array and enqueues a refresh on a cold cache' do
        expect(RefreshForumTopicsJob).to receive(:perform_later)
        expect(described_class.latest).to eq([])
      end

      it 'serves fresh cached topics without enqueueing a refresh' do
        cache_entry(fetched_at: Time.current)
        expect(RefreshForumTopicsJob).not_to receive(:perform_later)
        expect(described_class.latest).to eq(topics)
      end

      it 'serves stale cached topics and enqueues a refresh' do
        cache_entry(fetched_at: 2.hours.ago)
        expect(RefreshForumTopicsJob).to receive(:perform_later)
        expect(described_class.latest).to eq(topics)
      end

      it 'enqueues a refresh only once while the lock is held' do
        expect(RefreshForumTopicsJob).to receive(:perform_later).once
        2.times { described_class.latest }
      end
    end
  end
end
