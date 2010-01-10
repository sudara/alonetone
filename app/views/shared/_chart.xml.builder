#=<graph caption='Monthly Sales Summary' subcaption='For the year 2004' xAxisName='Month' yAxisMinValue='15000' yAxisName='Sales' decimalPrecision='0' formatNumberScale='0' numberPrefix='$' showNames='1' showValues='0'  showAlternateHGridColor='1' AlternateHGridColor='ff5904' divLineColor='ff5904' divLineAlpha='20' alternateHGridAlpha='5' >
#   <set name='Jan' value='17400' hoverText='January'/>
#   <set name='Feb' value='19800' hoverText='February'/>
#   <set name='Mar' value='21800' hoverText='March'/>
#   <set name='Apr' value='23800' hoverText='April'/>
#   <set name='May' value='29600' hoverText='May'/>
#   <set name='Jun' value='27600' hoverText='June'/>
#   <set name='Jul' value='31800' hoverText='July'/>
#   <set name='Aug' value='39700' hoverText='August'/>
#
#   <set name='Sep' value='37800' hoverText='September'/>
#   <set name='Oct' value='21900' hoverText='October'/>
#   <set name='Nov' value='32900' hoverText='November' />
#   <set name='Dec' value='39800' hoverText='December' />
#</graph>
xml.graph(chart_options(:caption => caption, 
  :formatNumber => 0
#  :xAxisName => "Month", 
#  :yAxisName => "Listens")
    ) do
    data.each do |ponint|
      xml.set(:name => point[0], 
     #   :color => get_chart_color,  
        :value => point[1])
    end
end