# -*- encoding : utf-8 -*-
module GchartHelpers
  def self.zero_half_max(max=0)
    max = max.to_i
    "0|#{(max+1)/2}|#{max}"
  end
end
