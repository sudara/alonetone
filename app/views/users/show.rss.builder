xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.rss "xmlns:itunes"=> "http://www.itunes.com/dtds/podcast-1.0.dtd", "version"=>"2.0" do
  xml.channel do 
    xml.itunes :block, 'yes' if @user.has_setting?('block_itunes','true')
    xml.title  "#{@user.name} on alonetone.com"
    
    xml.link  user_home_url(@user)
    xml.description  h(@user.bio)
    xml.language  "en-us"
    xml.lastBuildDate  rss_date((@assets.first || @user).created_at)
    
    xml.image do
      xml.url  @user.avatar(:album)
      xml.title  "Latest music from #{@user.name}"
      xml.width 200
      xml.height 200
    end
    
    
    xml.itunes :author, 	@user.name
		xml.itunes :subtitle, "#{@user.name} on alonetone.com"
		xml.itunes :summary, 	@user.bio || "Latest music from #{@user.name} on alonetone.com"
		xml.itunes :keywords, "independant free alonetone musician artist latest upcoming do-it-yourself DIY #{@user.name} #{@user.login}"
		xml.itunes :image, :href=>@user.avatar(:album)
		
		xml.itunes :owner do
			xml.itunes :name, 'alonetone'
			xml.itunes :email,	'support@alonetone.com'
		end
		
		xml.itunes :category,:text=>'Music' 
    
    xml.<< render(:partial => 'shared/asset', :collection => @assets) if @assets.present?
  end
end