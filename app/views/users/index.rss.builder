xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.rss "version" => "2.0", 
        "xmlns:geo"=> "http://www.w3.org/2003/01/geo/wgs84_pos#", 
        "xmlns:georss"=>"http://www.georss.org/georss" do
  xml.channel do 
    xml.title  "alonetone users around the world"
    
    xml.link  users_url
    xml.description  'alonetone musicians and listeners around the world'
    xml.language  "en-us"
    xml.lastBuildDate  rss_date(Time.now)
    xml.generator 'http://alonetone.com'
    
    for @user in @users do
      xml.item do
        xml.title "#{@user.name} on alonetone"
        xml.author "#{@user.name}"
        xml.link user_home_url(@user)
        xml.description "#{image_tag(@user.avatar(:large))}
          <br/>#{@user.name} 
          #{ @user.printable_bio if @user.bio }
          #{(@user.assets_count > 0) ? ('has '+ pluralize(@user.assets_count.to_s, 'track') + ' on alonetone <br/>') : ''}<br/>
          #{ link_to 'view more',user_home_url(@user)}"
        xml.georss :point, "#{@user.lat} #{@user.lng}"
        xml.geo :point do
          xml.geo :lat, @user.lat
          xml.geo :lng, @user.lng
        end
      end
    end
	end
end