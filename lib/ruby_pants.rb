# -*- encoding : utf-8 -*-
class RubyPants < String
  VERSION = "0.2"

  # Create a new RubyPants instance with the text in +string+.
  #
  # Allowed elements in the options array:
  # 
  # 0  :: do nothing
  # 1  :: enable all, using only em-dash shortcuts
  # 2  :: enable all, using old school en- and em-dash shortcuts (*default*)
  # 3  :: enable all, using inverted old school en and em-dash shortcuts
  # -1 :: stupefy (translate HTML entities to their ASCII-counterparts)
  #
  # If you don't like any of these defaults, you can pass symbols to change
  # RubyPants' behavior:
  #
  # <tt>:quotes</tt>        :: quotes
  # <tt>:backticks</tt>     :: backtick quotes (``double'' only)
  # <tt>:allbackticks</tt>  :: backtick quotes (``double'' and `single')
  # <tt>:dashes</tt>        :: dashes
  # <tt>:oldschool</tt>     :: old school dashes
  # <tt>:inverted</tt>      :: inverted old school dashes
  # <tt>:ellipses</tt>      :: ellipses
  # <tt>:convertquotes</tt> :: convert <tt>&quot;</tt> entities to
  #                            <tt>"</tt> for Dreamweaver users
  # <tt>:stupefy</tt>       :: translate RubyPants HTML entities
  #                            to their ASCII counterparts.
  #
  def initialize(string, options=[2])
    super string
    @options = [*options]
  end

  # Apply SmartyPants transformations.
  def to_html
    do_quotes = do_backticks = do_dashes = do_ellipses = do_stupify = nil
    convert_quotes = false

    if @options.include? 0
      # Do nothing.
      return self
    elsif @options.include? 1
      # Do everything, turn all options on.
      do_quotes = do_backticks = do_ellipses = true
      do_dashes = :normal
    elsif @options.include? 2
      # Do everything, turn all options on, use old school dash shorthand.
      do_quotes = do_backticks = do_ellipses = true
      do_dashes = :oldschool
    elsif @options.include? 3
      # Do everything, turn all options on, use inverted old school
      # dash shorthand.
      do_quotes = do_backticks = do_ellipses = true
      do_dashes = :inverted
    elsif @options.include?(-1)
      do_stupefy = true
    else
      do_quotes =                @options.include? :quotes
      do_backticks =             @options.include? :backticks
      do_backticks = :both    if @options.include? :allbackticks
      do_dashes = :normal     if @options.include? :dashes
      do_dashes = :oldschool  if @options.include? :oldschool
      do_dashes = :inverted   if @options.include? :inverted
      do_ellipses =              @options.include? :ellipses
      convert_quotes =           @options.include? :convertquotes
      do_stupefy =               @options.include? :stupefy
    end

    # Parse the HTML
    tokens = tokenize
    
    # Keep track of when we're inside <pre> or <code> tags.
    in_pre = false

    # Here is the result stored in.
    result = ""

    # This is a cheat, used to get some context for one-character
    # tokens that consist of just a quote char. What we do is remember
    # the last character of the previous text token, to use as context
    # to curl single- character quote tokens correctly.
    prev_token_last_char = nil

    tokens.each { |token|
      if token.first == :tag
        result << token[1]
        if token[1] =~ %r!<(/?)(?:pre|code|kbd|script|math)[\s>]!
          in_pre = ($1 != "/")  # Opening or closing tag?
        end
      else
        t = token[1]

        # Remember last char of this token before processing.
        last_char = t[-1].chr

        unless in_pre
          t = process_escapes t
          
          t.gsub!(/&quot;/, '"')  if convert_quotes

          if do_dashes
            t = educate_dashes t            if do_dashes == :normal
            t = educate_dashes_oldschool t  if do_dashes == :oldschool
            t = educate_dashes_inverted t   if do_dashes == :inverted
          end

          t = educate_ellipses t  if do_ellipses

          # Note: backticks need to be processed before quotes.
          if do_backticks
            t = educate_backticks t
            t = educate_single_backticks t  if do_backticks == :both
          end

          if do_quotes
            if t == "'"
              # Special case: single-character ' token
              if prev_token_last_char =~ /\S/
                t = "&#8217;"
              else
                t = "&#8216;"
              end
            elsif t == '"'
              # Special case: single-character " token
              if prev_token_last_char =~ /\S/
                t = "&#8221;"
              else
                t = "&#8220;"
              end
            else
              # Normal case:                  
              t = educate_quotes t
            end
          end

          t = stupefy_entities t  if do_stupefy
        end

        prev_token_last_char = last_char
        result << t
      end
    }

    # Done
    result
  end

  protected

  # Return the string, with after processing the following backslash
  # escape sequences. This is useful if you want to force a "dumb" quote
  # or other character to appear.
  #
  # Escaped are:
  #      \\    \"    \'    \.    \-    \`
  #
  def process_escapes(str)
    str.gsub('\\\\', '&#92;').
      gsub('\"', '&#34;').
      gsub("\\\'", '&#39;').
      gsub('\.', '&#46;').
      gsub('\-', '&#45;').
      gsub('\`', '&#96;')
  end

  # The string, with each instance of "<tt>--</tt>" translated to an
  # em-dash HTML entity.
  #
  def educate_dashes(str)
    str.gsub(/--/, '&#8212;')
  end

  # The string, with each instance of "<tt>--</tt>" translated to an
  # en-dash HTML entity, and each "<tt>---</tt>" translated to an
  # em-dash HTML entity.
  #
  def educate_dashes_oldschool(str)
    str.gsub(/---/, '&#8212;').gsub(/--/, '&#8211;')
  end

  # Return the string, with each instance of "<tt>--</tt>" translated
  # to an em-dash HTML entity, and each "<tt>---</tt>" translated to
  # an en-dash HTML entity. Two reasons why: First, unlike the en- and
  # em-dash syntax supported by +educate_dashes_oldschool+, it's
  # compatible with existing entries written before SmartyPants 1.1,
  # back when "<tt>--</tt>" was only used for em-dashes.  Second,
  # em-dashes are more common than en-dashes, and so it sort of makes
  # sense that the shortcut should be shorter to type. (Thanks to
  # Aaron Swartz for the idea.)
  #
  def educate_dashes_inverted(str)
    str.gsub(/---/, '&#8211;').gsub(/--/, '&#8212;')
  end

  # Return the string, with each instance of "<tt>...</tt>" translated
  # to an ellipsis HTML entity. Also converts the case where there are
  # spaces between the dots.
  #
  def educate_ellipses(str)
    str.gsub('...', '&#8230;').gsub('. . .', '&#8230;')
  end

  # Return the string, with "<tt>``backticks''</tt>"-style single quotes
  # translated into HTML curly quote entities.
  #
  def educate_backticks(str)
    str.gsub("``", '&#8220;').gsub("''", '&#8221;')
  end

  # Return the string, with "<tt>`backticks'</tt>"-style single quotes
  # translated into HTML curly quote entities.
  #
  def educate_single_backticks(str)
    str.gsub("`", '&#8216;').gsub("'", '&#8217;')
  end

  # Return the string, with "educated" curly quote HTML entities.
  #
  def educate_quotes(str)
    punct_class = '[!"#\$\%\'()*+,\-.\/:;<=>?\@\[\\\\\]\^_`{|}~]'

    str = str.dup
      
    # Special case if the very first character is a quote followed by
    # punctuation at a non-word-break. Close the quotes by brute
    # force:
    str.gsub!(/^'(?=#{punct_class}\B)/, '&#8217;')
    str.gsub!(/^"(?=#{punct_class}\B)/, '&#8221;')

    # Special case for double sets of quotes, e.g.:
    #   <p>He said, "'Quoted' words in a larger quote."</p>
    str.gsub!(/"'(?=\w)/, '&#8220;&#8216;')
    str.gsub!(/'"(?=\w)/, '&#8216;&#8220;')

    # Special case for decade abbreviations (the '80s):
    str.gsub!(/'(?=\d\ds)/, '&#8217;')

    close_class = %![^\ \t\r\n\\[\{\(\-]!
    dec_dashes = '&#8211;|&#8212;'
    
    # Get most opening single quotes:
    str.gsub!(/(\s|&nbsp;|--|&[mn]dash;|#{dec_dashes}|&#x201[34];)'(?=\w)/,
             '\1&#8216;')
    # Single closing quotes:
    str.gsub!(/(#{close_class})'/, '\1&#8217;')
    str.gsub!(/'(\s|s\b|$)/, '&#8217;\1')
    # Any remaining single quotes should be opening ones:
    str.gsub!(/'/, '&#8216;')

    # Get most opening double quotes:
    str.gsub!(/(\s|&nbsp;|--|&[mn]dash;|#{dec_dashes}|&#x201[34];)"(?=\w)/,
             '\1&#8220;')
    # Double closing quotes:
    str.gsub!(/(#{close_class})"/, '\1&#8221;')
    str.gsub!(/"(\s|s\b|$)/, '&#8221;\1')
    # Any remaining quotes should be opening ones:
    str.gsub!(/"/, '&#8220;')

    str
  end

  # Return the string, with each RubyPants HTML entity translated to
  # its ASCII counterpart.
  #
  # Note: This is not reversible (but exactly the same as in SmartyPants)
  #
  def stupefy_entities(str)
    str.
      gsub(/&#8211;/, '-').      # en-dash
      gsub(/&#8212;/, '--').     # em-dash
      
      gsub(/&#8216;/, "'").      # open single quote
      gsub(/&#8217;/, "'").      # close single quote
      
      gsub(/&#8220;/, '"').      # open double quote
      gsub(/&#8221;/, '"').      # close double quote
      
      gsub(/&#8230;/, '...')     # ellipsis
  end

  # Return an array of the tokens comprising the string. Each token is
  # either a tag (possibly with nested, tags contained therein, such
  # as <tt><a href="<MTFoo>"></tt>, or a run of text between
  # tags. Each element of the array is a two-element array; the first
  # is either :tag or :text; the second is the actual value.
  #
  # Based on the <tt>_tokenize()</tt> subroutine from Brad Choate's
  # MTRegex plugin.  <http://www.bradchoate.com/past/mtregex.php>
  #
  # This is actually the easier variant using tag_soup, as used by
  # Chad Miller in the Python port of SmartyPants.
  #
  def tokenize
    tag_soup = /([^<]*)(<[^>]*>)/

    tokens = []

    prev_end = 0
    scan(tag_soup) {
      tokens << [:text, $1]  if $1 != ""
      tokens << [:tag, $2]
      
      prev_end = $~.end(0)
    }

    if prev_end < size
      tokens << [:text, self[prev_end..-1]]
    end

    tokens
  end
end
