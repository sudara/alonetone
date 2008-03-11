class PrettyTextTestsController < ActionController::Base

  before_filter :clear_cache?
  layout nil
  
  def index
    @fonts = %w(VeraMolt.ttf Veralt.ttf VeraSe.ttf VeraSeBd.ttf VeraMono.ttf VeraBl.ttf VeraMoBl.ttf VeraMoBd Vera.ttf)
    
  end
  
  protected
  
  def clear_cache?
    params[:cache] == false ? @cache= false : @cache = true
  end
end