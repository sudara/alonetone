# Wow, ugliest 3rd party lib ever.
# Can't complain too much though, yay for free charts!
# cleaned up a bit...

module ChartsHelper 

  # Contains an array of colors to be used as default set of colors for FusionCharts
  # arr_FCColors is the array that would contain the hex code of colors 
  # ALL COLORS HEX CODES TO BE USED WITHOUT #


  # We also initiate a counter variable to help us cyclically rotate through
  # the array of colors.
  
  @@FC_ColorCounter = 0;
  @@arr_FCColors = ["1941A5" , "AFD8F8" , "F6BD0F" , "8BBA00" , "A66EDD" , "F984A1" , "CCCC00" , "999999" , "0099CC" , "FF0000" ,  "006F00",  "0099FF",  "FF66CC",  "669966",  "7C7CB4",  "FF9933",  "9900FF",  "99FFCC",  "CCCCFF",  "669900"]
  
  
  
  # get_chart_color function helps return a color from arr_FCColors array. It uses
  # cyclic iteration to return a color from a given index. The index value is
  # maintained in FC_ColorCounter
  def get_chart_color 
    #Update index
    @@FC_ColorCounter=@@FC_ColorCounter+1
    counter = @@FC_ColorCounter % (@@arr_FCColors.size)
    #Return color
    return @@arr_FCColors[counter]
  end
  
  def chart_options(options)
    options.merge({ :bgColor => 'E1E2E1',
                    :canvasBgColor => 'f6fceb',
                    :baseFontColor => "37392B",
                    :baseFontSize => 10,
                    :outCnvBaseFontSze => 14,
                    :baseFont => "Helvetica,Arial,Geneva"})
  end
  
  # Renders a chart from the swf file passed as parameter either making use of setDataURL method or
  # setDataXML method. The width and height of chart are passed as parameters to this function. If the chart is not rendered,
  # the errors can be detected by setting debugging mode to true while calling this function. This feature is not available in free version. The view file can be registered to include javascript statements
  # by setting registering with javascript to true while calling this function.
  # - parameter chart_swf :  pass swf file that renders the chart. 
  # - parameter str_url :  URL path to the xml file.
  # - parameter str_xml :  XML content.
  # - parameter chart_id : Id for the chart, using which it will be identified in the page. Each chart on the page needs to have a unique Id. Datatype: String 
  # - parameter chart_width : Integer for the width of the chart in pixels.
  # - parameter chart_height : Integer for the height of the chart in pixels.
  # - parameter debug_mode : (Not used in Free version) If value is true, chart is shown in debug mode.
  # - parameter register_with_js : (Not used in Free version) If value is true, the chart is registered with javascript
  # Can be called from html block int he view where the chart needs to be embedded.
  def fusion_chart(chart_swf,url_or_xml,chart_id,chart_width,chart_height,debug_mode,register_with_js)
    chart_width=chart_width.to_s
    chart_height=chart_height.to_s
    
    register_with_js_num="0";
    
    debug_mode_num = debug_mode ? "1" : "0"
    register_with_js_num = register_with_js ? "1" : "0"

    
    result = ""
    result += "\t\t<!-- START Script Block for Chart "+chart_id+" -->\n\t\t"
    result += content_tag("div","\n\t\t\t\tChart.\n\t\t",{:id=>chart_id+"Div",:align=>"center"})
    result += "\n\t\t<script type='text/javascript'>\n"
    
    result += "\t\t\t\tvar chart_"+chart_id+"=new FusionCharts('"+chart_swf+"','"+chart_id+"',"+chart_width+","+chart_height+","+debug_mode_num+","+register_with_js_num+");\n"
    
    if url_or_xml.match('/')
      result += "\t\t\t\t<!-- Set the dataURL of the chart -->\n"
      result += "\t\t\t\tchart_"+chart_id+".setDataURL(\""+CGI::escape(url_or_xml)+"\");\n"
      logger.info("The method used is setDataURL.The URL is " + url_or_xml)
    else
      result += "\t\t\t\t<!-- Provide entire XML data using DataXML method -->\n"
      result += "\t\t\t\t"
      result += 'chart_'+chart_id+'.setDataXML(\''+url_or_xml+'\');'
      result += "\n"
      logger.info("The method used is setDataXML.The XML is " + url_or_xml)
    end
    
    result += "\t\t\t\t<!-- Finally render the chart. -->\n"
    result += "\t\t\t\tchart_"+chart_id+".render('"+chart_id+"Div');\n"
    result += "\t\t</script>\n"
    result += "\t\t<!-- END Script Block for Chart "+chart_id+" -->\n"
    result
  end
  # Renders a chart from the swf file passed as parameter either making use of setDataURL method or 
  # setDataXML method. The width and height of chart are passed as parameters to this function. If the chart is not rendered,
  # the errors can be detected by setting debugging mode to true while calling this function.
  # - parameter chart_swf :  SWF file that renders the chart. 
  # - parameter str_url : URL path to the xml file.
  # - parameter str_xml : XML content.
  # - parameter chart_id :  String for identifying chart.
  # - parameter chart_width : Integer for the width of the chart.
  # - parameter chart_height : Integer for the height of the chart.
  # - parameter debug_mode :  (Not used in Free version)True ( a boolean ) for debugging errors, if any, while rendering the chart.
  # Can be called from html block in the view where the chart needs to be embedded.
  def render_chart_html(chart_swf,str_url,str_xml,chart_id,chart_width,chart_height,debug_mode,&block)
    result = ""
    chart_width=chart_width.to_s
    chart_height=chart_height.to_s
    
    debug_mode_num="0"
    if debug_mode==true
      debug_mode_num="1"
    end 
    
    str_flash_vars=""
    if str_xml==""
      str_flash_vars="chartWidth="+chart_width+"&chartHeight="+chart_height+"&debugmode="+debug_mode_num+"&dataURL="+str_url
      logger.info("The method used is setDataURL.The URL is " + str_url)
    else
      str_flash_vars="chartWidth="+chart_width+"&chartHeight="+chart_height+"&debugmode="+debug_mode_num+"&dataXML="+str_xml
      logger.info("The method used is setDataXML.The XML is " + str_xml)
    end
    result += "\t\t<!-- START Code Block for Chart "+chart_id+" -->\n\t\t"
    
    object_attributes={:classid=>"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"}
    object_attributes=object_attributes.merge(:codebase=>"http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0")
    object_attributes=object_attributes.merge(:width=>chart_width)
    object_attributes=object_attributes.merge(:height=>chart_height)
    object_attributes=object_attributes.merge(:id=>chart_id)
    
    param_attributes1={:name=>"allowscriptaccess",:value=>"always"}
    param_tag1=content_tag("param","",param_attributes1)
    
    param_attributes2={:name=>"movie",:value=>chart_swf}
    param_tag2=content_tag("param","",param_attributes2)
    
    param_attributes3={:name=>"FlashVars",:value=>str_flash_vars}
    param_tag3=content_tag("param","",param_attributes3)
    
    param_attributes4={:name=>"quality",:value=>"high"}
    param_tag4=content_tag("param","",param_attributes4)
    
    embed_attributes={:src=>chart_swf}
    embed_attributes=embed_attributes.merge(:FlashVars=>str_flash_vars)
    embed_attributes=embed_attributes.merge(:quality=>"high")
    embed_attributes=embed_attributes.merge(:width=>chart_width)
    embed_attributes=embed_attributes.merge(:height=>chart_height).merge(:name=>chart_id)
    embed_attributes=embed_attributes.merge(:allowScriptAccess=>"always")
    embed_attributes=embed_attributes.merge(:type=>"application/x-shockwave-flash")
    embed_attributes=embed_attributes.merge(:pluginspage=>"http://www.macromedia.com/go/getflashplayer")
    
    embed_tag=content_tag("embed","",embed_attributes)
    
    result += content_tag("object","\n\t\t\t\t"+param_tag1+"\n\t\t\t\t"+param_tag2+"\n\t\t\t\t"+param_tag3+"\n\t\t\t\t"+param_tag4+"\n\t\t\t\t"+embed_tag+"\n\t\t",object_attributes)
    result += "\n\t\t<!-- END Code Block for Chart "+chart_id+" -->\n"
    result
  end
  
  # Uses render_component.  
  # Renders a chart using the swf file passed as parameter by calling an action to get the xml for the 
  # setDataXML method. The width and height of chart are passed as parameters to this function. If the chart is not rendered,
  # the errors can be detected by setting debugging mode to true while calling this function.
  # - parameter chart_swf :  SWF file that renders the chart. 
  # - parameter controller_name : The complete name of the controller containing the action.
  # - parameter action_name : The name of the action which will provide the xml.
  # - parameter chart_id :  String for identifying chart.
  # - parameter chart_width : Integer for the width of the chart.
  # - parameter chart_height : Integer for the height of the chart.
  # - parameter debug_mode : (Not used in Free version) If value is true, chart is shown in debug mode.
  # - parameter register_with_js : (Not used in Free version) If value is true, the chart is registered with javascript  
  # Can be called from html block in the view where the chart needs to be embedded.
  def render_chart_get_xml_from_action(chart_swf,controller_name,action_name,params,chart_id,chart_width,chart_height,debug_mode,register_with_js,&block)
    logger.info("The controller to be contacted is " + controller_name)
    logger.info("The action to be performed is " + action_name)
    str_xml= render_component(:action=>action_name,:controller=>controller_name,:params=>params)
    logger.info("The xml obtained from the given action is " + str_xml)
    render_chart(chart_swf,"",str_xml,chart_id,chart_width,chart_height,debug_mode,register_with_js,&block)
  end
  
  # This function can be used when time needs to be added to the URL
  # This will help avoiding cache of the page rendered by the URL
  # Can be used for dataURL method
  def add_cache_to_data_url(str_data_url)
    cache_buster= Time.now.strftime('%d_%m_%y_%H_%M_%S')
    if(str_data_url.index('?')==nil)
      str_data_url = str_data_url + "?FCCurrTime=" + cache_buster.to_s
    else
      str_data_url = str_data_url + "&FCCurrTime=" + cache_buster.to_s
    end
    logger.info("The URL after appending time is " + str_data_url)
    return str_data_url
  end
  
  # This function returns the BOM for UTF8.
  # BOM needs to be placed as first few bytes in the xml before providing to the chart.
  # This can be used in the XML provider views.
  def get_UTF8_BOM
    
    utf8_arr=[0xEF,0xBB,0xBF]
    utf8_str = utf8_arr.pack("c3")
    
    return utf8_str
  end
  
end