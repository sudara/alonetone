module GchartHelpers
  def self.zero_half_max(max)
    max ||= 0
    "0|#{(max+1)/2}|#{max}"
  end
end