module PreventAbuse
  @@bad_ip_ranges = ['195.239', '220.181', '61.135', '60.28.232', '121.14', '221.194','117.41.183',
                     '117.41.184','60.169.78','222.186','61.160.232','60.169.75','60.169.78','120.35.102', '110.84.8'] 

  def is_from_a_bad_ip?
    @@bad_ip_ranges.any?{|cloaked_ip| request.ip.match /^#{cloaked_ip}/  } # check bad ips 
  end
end
