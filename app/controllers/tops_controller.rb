class TopsController < ApplicationController
  # before_action :confirm_user_token, only: :fetch_work_session
  before_action :set_session_keys, only: [:index, :fetch_work_session, :session_hash]

  # get method of index
  def main_method
    # logger.debug current_user
    st = get_session
    gon.session_keys = Grobal::loop_session_keys + Grobal::non_loop_session_keys
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
    upk_list = get_session.get_next_url_list
    ret = edit_code(get_next_url_list)
    ret['session'] = get_session.session_hash
    render json: ret.to_json
  end

  def index
    if request.post?
      sub_method
    else
      main_method
    end
  end

  def nopage
    render 'errors/not_found_error', status: 404, layout: 'simple'
  end
  
  def unmatched
    redirect_to no_page_path
  end

  def header    
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

end
