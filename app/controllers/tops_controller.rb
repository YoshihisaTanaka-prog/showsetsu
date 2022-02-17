class TopsController < ApplicationController
  # before_action :confirm_user_token, only: :fetch_work_session
  before_action :set_session_keys, only: [:index, :fetch_work_session, :session_hash]

  # get method of index
  def main_method
    gon.session_keys = @loop_session_keys + @non_loop_session_keys
    if user_signed_in?
      current_user.set_token
      if current_user.initial_step.blank?
        @mode = 'set_step'
      else
        @mode = 'edit'
      end
      gon.session_info = current_user.session_hash
      if current_user.admin
        respond_to do |format|
          format.html
          format.xlsx{
            @tables = [Step, Title, Chapter, Story, Synopsis, Character, ChapterCharacter, ChapterSynopsis]
          }
        end
      end
    else
      gon.session_info = session_hash
      @mode = 'watch'
    end
  end

  # post method of index
  def sub_method
    upk_list = []
    if user_signed_in?
      render json: edit_code(get_next_url_list)
    else
    end
  end

  def index
    if request.post?
      sub_method
    else
      main_method
    end
  end

  def fetch_work_session
    if user_signed_in?
      if params[:step].present?
        current_user.step = params[:step]
        @loop_session_keys.each do |prop|
          current_user[prop] = nil
        end
      else
        current_user.step = nil
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
      end
      current_user.set_token
      render json: current_user.session_hash
    else
      render json: session_hash
    end
  end

  def nopage
    render 'errors/not_found_error', status: 404, layout: 'simple'
  end
  
  def unmatched
    redirect_to no_page_path
  end

  private

  def session_hash
    ret = {step: -1}
    for key in @loop_session_keys
      ret[key] = nil
    end
    return ret
  end

  def set_session_keys
    @loop_session_keys = ['title','chapter','story','synopsis','character']
    @non_loop_session_keys = ['design', 'step', 'mode']
  end

  def get_next_url_list
    params.each do |key, value|
      logger.debug key + ' >> ' + value.to_s
    end
    if params[:step].present?
      if params[:step].to_i == -1
        return [{uri: 'steps/index', params: {controller: 'steps', action: 'index'}, key: 'body-main'}]
      elsif params[:step].to_i == 0
        return [{uri: 'steps/new', params: {controller: 'steps', action: 'index'}, key: 'body-main'}]
      else
        return [{uri: 'steps/' + params[:step] + '/' + params[:mode], params: {controller: 'steps', action: 'index'}, key: 'body-main'}]
      end
    elsif params[:title].present?
      if params[:chapter].present?
        if params[:story].present?
          return [
            {uri: 'titles/' + params[:title] + '/' + params[:mode], params: {}, key: ''},
            {uri: 'chapters/' + params[:chapter] + '/' + params[:mode], params: {}, key: ''},
            {uri: 'stories/' + params[:story] + '/' + params[:mode], params: {}, key: ''}
          ]
        elsif params[:synopsis].present?
          return [
            {uri: 'titles/' + params[:title] + '/' + params[:mode], params: {}, key: ''},
            {uri: 'chapters/' + params[:chapter] + '/' + params[:mode], params: {}, key: ''},
            {uri: 'synopsis/' + params[:synopsis] + '/' + params[:mode], params: {}, key: ''}
          ]
        elsif params[:character].present?
          return [
            {uri: 'titles/' + params[:title] + '/' + params[:mode], params: {}, key: ''}, 
            {uri: 'chapters/' + params[:chapter] + '/' + params[:mode], params: {}, key: ''},
            {uri: 'character/' + params[:character] + '/' + params[:mode], params: {}, key: ''}
          ]
        else
          return [
            {uri: 'titles/' + params[:title] + '/' + params[:mode], params: {}, key: ''},
            {uri: 'chapters/' + params[:chapter] + '/' + params[:mode], params: {}, key: ''}
          ]
        end
      else
        return [{uri: 'titles/' + params[:title] + '/' + params[:mode], params: {}, key: ''}]
      end
    else
      return [{uri: 'titles/index', params: {}, key: ''}]
    end
  end

end
