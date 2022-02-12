class TopsController < ApplicationController
  before_action :confirm_user_token, only: :fetch_work_session
  before_action :set_session_keys, only: [:index, :fetch_work_session, :session_hash]

  def index

    @tables = [Step, Title, Chapter, Story, Synopsis, Character, ChapterCharacter, ChapterSynopsis]
    
    gon.session_keys = @loop_session_keys + @non_loop_session_keys
    if user_signed_in?
      current_user.set_token
      gon.session_info = current_user.session_hash
      if current_user.admin
        respond_to do |format|
          format.html
          format.xlsx
        end
      end
    else
      gon.session_info = session_hash
    end
    logger.debug gon.to_json
  end

  def fetch_work_session
    if user_signed_in?
      if params[:title].blank? || current_user.steps.length == 0
        @loop_session_keys.each do |prop|
          current_user[prop] = nil
        end
      elsif params[:chapter].blank?
        @loop_session_keys.each_with_index do |prop, i|
          current_user[prop] = params[prop]
        end
        current_user.title = params[:title]
      elsif (!params[:story].blank? && !params[:synopsis].blank?) || (!params[:synopsis].blank? && !params[:character].blank?) || (!params[:character].blank? && !params[:story].blank?)
        for i in 0..1 do
          current_user[@loop_session_keys[i]] = params[@loop_session_keys[i]]
        end
        for i in 2..4 do
          current_user[@loop_session_keys[i]] = nil
        end
      else
        @loop_session_keys.each do |prop|
          current_user[prop] = params[prop]
        end
      end
      if params[:design].blank?
        current_user.design = nil
      else
        current_user.design = params[:design]
      end
      current_user.set_token
      render json: current_user.session_hash
    else
      render json: session_hash
    end
  end

  def nopage
    render 'errors/not_found_error', status: 404
  end
  
  def unmatched
    redirect_to no_page_path
  end

  private

  def session_hash
    new_token = ''
    for i in 0..254
      r = rand 61
     if r < 10
      new_token = new_token + r.to_s
     elsif r < 36
      new_token = new_token + (r + 55).chr
     else
      new_token = new_token + (r + 61).chr
     end
    end
    session[:token] = new_token
    ret = {step: -1, token: session[:token]}
    for key in @loop_session_keys
      ret[key] = nil
    end
    return ret
  end

  def set_session_keys
    @loop_session_keys = ['title','chapter','story','synopsis','character']
    @non_loop_session_keys = ['design', 'token', 'step']
  end

end
