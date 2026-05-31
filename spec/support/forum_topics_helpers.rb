# The logged-in footer fetches forum topics over the network. WebMock raises
# NetConnectNotAllowedError, which isn't a StandardError, so ForumTopics' own
# rescue misses it and the footer 500s in every logged-in feature spec. Stub it.
RSpec.configure do |config|
  config.before(:each, type: :feature) do
    allow(ForumTopics).to receive(:latest).and_return([])
  end
end
