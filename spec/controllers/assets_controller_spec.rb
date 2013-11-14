require File.dirname(__FILE__) + '/../spec_helper'

describe AssetsController do
  fixtures :assets, :users
  
  context "#latest" do
    it "should render the home page" do 
      get :latest
      response.should be_success
    end
  end
  
  context "#show.mp3" do
    subject do
      request.env["HTTP_ACCEPT"] = "audio/mpeg" 
      get :show, :id => 'song1', :user_id => users(:sudara).login, :format => :mp3
    end
  
    GOOD_USER_AGENTS = [
      "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en) AppleWebKit/XX (KHTML, like Gecko) Safari/YY",
      "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8) Gecko/20060319 Firefox/2.0",
      "iTunes/x.x.x",
      "Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)",
      "msie",
      'webkit'
      ]
    
    BAD_USER_AGENTS = [
      "Mp3Bot/0.1 (http://mp3realm.org/mp3bot/)",
      "",
      "Googlebot/2.1 (+http://www.google.com/bot.html)",
      "you're momma's so bot...",
      "Baiduspider+(+http://www.baidu.jp/spider/)",
      "baidu/Nutch-1.0 "
    ]
  
    GOOD_USER_AGENTS.each do |agent|
      it "should register a listen for #{agent}" do
        request.user_agent = agent
        expect{ subject }.to change{ Listen.count }.by(1)  
      end
    end
  
    BAD_USER_AGENTS.each do |agent|
      it "should not register a listen for #{agent}" do
        request.user_agent = agent
        expect{ subject }.not_to change{ Listen.count }.by(1)  
      end
    end
  
    it "should NOT register more than one listen from one ip/track in short amount of time" do 
      request.user_agent = GOOD_USER_AGENTS.first
      expect do
        request.env["HTTP_ACCEPT"] = "audio/mpeg" 
        get :show, :id => 'song1', :user_id => users(:sudara).login, :format => :mp3
        get :show, :id => 'song1', :user_id => users(:sudara).login, :format => :mp3
        get :show, :id => 'song1', :user_id => users(:sudara).login, :format => :mp3
      end.to change{ Listen.count }.by(1)  
    end
    
    it 'should allow more than one listen to be created by same ip over reasonable amount of time' do
      request.user_agent = GOOD_USER_AGENTS.first
            expect do
        request.env["HTTP_ACCEPT"] = "audio/mpeg" 
        Timecop.travel(3.hours.ago) do
          get :show, :id => 'song1', :user_id => users(:sudara).login, :format => :mp3
        end
        Timecop.travel(2.hours.ago) do
          get :show, :id => 'song1', :user_id => users(:sudara).login, :format => :mp3
        end
        Timecop.travel(1.hour.ago)do
          get :show, :id => 'song1', :user_id => users(:sudara).login, :format => :mp3
        end
      end.to change{Listen.count}.by(3)
      Timecop.return
    end
    
    it 'should accept a mp3 extension and redirect to the amazon url' do
      request.env["HTTP_ACCEPT"] = "audio/mpeg" 
      request.user_agent = GOOD_USER_AGENTS.first
      subject
      response.should redirect_to(assets(:valid_mp3).mp3.url)
    end
  
    it 'should have a landing page' do
      request.user_agent = GOOD_USER_AGENTS.first
      get :show, :id => 'song1', :user_id => users(:sudara).login
      assigns(:assets).should be_present
      response.response_code.should == 200
    end

    it 'should properly detect leeching blacklisted sites and not register a listen' do
      request.user_agent = 'mp3bot'
      expect{ subject }.not_to change(Listen, :count)
      response.response_code.should == 403
    end

    it 'should consider an empty user agent to be a spider and not register a listen' do
      request.user_agent = ''
      expect{ subject }.not_to change(Listen, :count)
    end
  
    it 'should consider any user agent with BOT in its string a bot and not register a listen' do
      request.user_agent = 'bot'
      expect{ subject }.not_to change(Listen, :count)    
    end
  end
  
  context '#create' do
    subject do
      login(:sudara)
      post :create, :user_id => users(:sudara).login, :asset_data => [fixture_file_upload('assets/muppets.mp3','audio/mpeg')]
    end
    
    it 'should successfully upload an mp3' do 
      expect { subject }.to change{ Asset.count }.by(1)
      flash[:error].should_not be_present      
      response.should redirect_to('http://test.host/sudara/tracks/mass_edit?assets%5B%5D='+Asset.last.id.to_s)
    end
    
    it 'should accept an uploaded mp3 from chrome' do
      login(:sudara)
      post :create, :user_id => users(:sudara).login, :asset_data => [fixture_file_upload('assets/muppets.mp3','audio/mp3')]
      flash[:error].should_not be_present      
      response.should redirect_to('http://test.host/sudara/tracks/mass_edit?assets%5B%5D='+Asset.last.id.to_s)
    end
    
    it "should email out followers on upload" do 
      users(:arthur).add_or_remove_followee(users(:sudara).id)
      expect { subject }.to change {ActionMailer::Base.deliveries.size}.by(1)
    end
    
    
    it 'should successfully upload 2 mp3s' do 
      login(:sudara)
      post :create, :user_id => users(:sudara).login, :asset_data => [fixture_file_upload('assets/muppets.mp3','audio/mpeg'),
        fixture_file_upload('assets/muppets.mp3','audio/mpeg')]
      flash[:error].should_not be_present      
      response.should redirect_to('http://test.host/sudara/tracks/mass_edit?assets%5B%5D='+Asset.last(2).first.id.to_s + '&assets%5B%5D=' + Asset.last.id.to_s )
    end
  end
  
  context "#mass_edit" do 
    
    it 'should allow user to edit 1 track' do 
      login(:arthur)
      get :mass_edit, :user_id => users(:arthur).login, :assets => [assets(:valid_arthur_mp3).id]
      response.should be_success
      assigns(:assets).should include(assets(:valid_arthur_mp3))
    end
    
    it 'should allow user to edit 2 tracks at once' do 
      login(:sudara)
      two_assets = [users(:sudara).assets.first,  users(:sudara).assets.last]
      get :mass_edit, :user_id => users(:sudara).login, :assets => two_assets.collect(&:id)
      response.should be_success
      assigns(:assets).should include(two_assets.first)
      assigns(:assets).should include(two_assets.last)
    end
    
    it 'should not allow user to edit other peoples tracks' do
      login(:arthur)
      get :mass_edit, :user_id => users(:arthur).login, :assets => [assets(:valid_mp3).id]
      response.should be_success # no wrong answer here :)
      assigns(:assets).should_not include(assets(:valid_mp3))
      assigns(:assets).should be_present # should be populated with user's own assets
    end
  end
  
end
