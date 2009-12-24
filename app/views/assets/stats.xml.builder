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
xml.graph(:caption => "Listens for #{@asset.name}", 
  :formatNumber => 0,
  :lineThickness => 3,
  :bgColor => 'E1E2E1',
  :canvasBgColor => 'f6fceb',
  :baseFontColor => "37392B",
  :baseFontSize => 10,
  :outCnvBaseFontSze => 14,
  :baseFont => "Helvetica,Arial,Geneva",
  :xAxisName => "Month", 
  :yAxisName => "Listens") do
    start = Date.today.beginning_of_month - 1.year
    plays_by_month = @asset.plays_by_month
    while start < Date.today.beginning_of_month
      start += 1.month
      xml.set(:name => start.to_s(:short_month), 
     #   :color => get_chart_color,  
        :value => plays_by_month[start.month.to_s] || 0, 
        :hover_text => start.to_s(:long_month_and_year) )
    end
end