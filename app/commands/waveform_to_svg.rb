#
#         |
#        |||  ||
#     ––|||||||||----
#        |||  ||
#         |
#
class WaveformToSvg
  attr_reader :array, :height, :width, :data

  def initialize(data)
    # Our waveforms have 500 datapoints
    @width = Waveform::LENGTH

    # internal height of svg, used to scale up
    @height = 54

    if data.length < 2
      @data = default_waveform
    else
      @data = data
    end

    scale_data!
  end

  # Proof of concept: https://codepen.io/sudara/pen/wvwNadB
  def points
    center = height / 2
    top_half = bottom_half = ""
    @data.each_with_index do |y, x|
      top_half += " #{x},#{center - (y * center)}"
    end
    @data.reverse.each_with_index do |y, x|
      x = @data.length - x - 1
      bottom_half += " #{x},#{center + (y * center)}"
    end
    top_half + bottom_half
  end

  private

  def scale_data!
    scale = [@data.max.abs, @data.min.abs].max.to_f
    @data.collect! { |sample| (sample.abs.to_f / scale)**0.7 }
  end

  private

  def default_waveform
    [0, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1,
    0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9,
    1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1,
    0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0.9, 1, 0]
  end
end