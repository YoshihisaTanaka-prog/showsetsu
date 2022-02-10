class TopsController < ApplicationController
  before_action :authenticate_user!, only: :fetch_work_session
  protect_from_forgery except: :fetch_work_session

    def index
      @tables = [Step, Title, Chapter, Story, Synopsis, Character, ChapterCharacter, ChapterSynopsis]
      
      if user_signed_in?
        user_session_hash = current_user.session_hash
        gon.title = user_session_hash[:title]
        gon.chapter = user_session_hash[:chapter]
        gon.story = user_session_hash[:story]
        gon.synopsis = user_session_hash[:synopsis]
        gon.character = user_session_hash[:character]
        gon.design = user_session_hash[:design]
      end
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def fetch_work_session
      [:title, :chapter, :story, :synopsis, :character, :design].each do |prop|
        if params[prop].blank?
          current_user[prop] = nil
        else
          current_user[prop] = params[prop]
        end
      end
      current_user.save
      render json: current_user.session_hash
    end

end
