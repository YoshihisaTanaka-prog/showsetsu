class TopsController < ApplicationController

    def index
        set_new_token
        unless session[:title].blank?
          gon.title = session[:title]
        end
    end

end
