require File.dirname(__FILE__) + '/../spec_helper'

describe AssetsController do
  fixtures :assets, :users
  
  @good_user_agents = [
    "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en) AppleWebKit/XX (KHTML, like Gecko) Safari/YY",
    "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8) Gecko/20060319 Firefox/2.0",
    "iTunes/x.x.x",
    "Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)",
    "msie",
    'webkit'
        
    ]
    
  @bad_user_agents = [
    "Mp3Bot/0.1 (http://mp3realm.org/mp3bot/)",
    "",
    "Googlebot/2.1 (+http://www.google.com/bot.html)",
    "you're momma's so bot..."
  ]
  
  
  it 'should accept a mp3 extension and redirect to the amazon url' do
    request.env["HTTP_ACCEPT"] = "audio/mpeg" 
    get :show, :id => 'song1', :login => users(:sudara).login, :format => 'mp3'
    response.should redirect_to(assets(:valid_mp3).public_mp3)
  end
  
  it 'should have a landing page' do
    get :show, :id => 'song1', :login => users(:sudara).login
    response.should be_success
  end

  it 'should properly detect leeching blacklisted sites and not register a listen' do
    request.user_agent = 'mp3bot'
    lambda{get_song }.should_not change(Listen, :count)
    response.response_code.should == 403
  end

  it 'should consider an empty user agent to be a spider and not register a listen' do
    request.user_agent = ''
    lambda{get_song }.should_not change(Listen, :count)
  end
  
  it 'should consider any user agent with BOT in its string a bot and not register a listen' do
    request.user_agent = 'bot'
    lambda{get_song }.should_not change(Listen, :count)    
  end
  
  @good_user_agents.each do |agent|
    it "should register a listen for #{agent}" do
      request.user_agent = agent
      lambda{get_song }.should change(Listen, :count).by(1)  
    end
  end
  
  def get_song
     get :show, :id => 'song1', :login => users(:sudara).login, :format => 'mp3'   
  end

end
