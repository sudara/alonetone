class FacebookPublisher < Facebooker::Rails::Publisher
  def track_added(user, track)
    send_as :action
    from(user)
    title "#{fb_name(user, :linked => true)} added the song '#{h track.name}' from #alonetone " <<
          "artist #{h(track.user.name)} to #{fb_pronoun(user, :possessive => true)} profile."
  end
end