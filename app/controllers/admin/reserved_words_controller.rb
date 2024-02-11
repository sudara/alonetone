module Admin
  class ReservedWordsController < Admin::BaseController
    before_action :find_reserved_word, only: %i[delete]

    def index
        @pagy, @reserved_words = pagy(ReservedWord.all)
    end

    def new
      @reserved_word = ReservedWord.new
    end

    def create
      @reserved_word = ReservedWord.new(reserved_word_params)
      
      if @reserved_word.save
        redirect_to admin_reserved_words_url
      else
        render :new
      end
    end

    def delete
      @reserved_word.destroy
      redirect_to admin_reserved_words_url
    end

    private
    
    def find_reserved_word
      @reserved_word = ReservedWord.find(params[:id])
    end

    def reserved_word_params
      params.require(:reserved_word).permit(:name)
    end
  end
end
