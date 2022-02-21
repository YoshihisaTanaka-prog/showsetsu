class TopsController < ApplicationController
  # before_action :confirm_user_token, only: :fetch_work_session
  before_action :set_session_keys, only: [:index, :fetch_work_session, :session_hash]

  # get method of index
  def main_method
    # logger.debug current_user
    st = get_session
    gon.session_keys = @loop_session_keys + @non_loop_session_keys
    if user_signed_in?
      if current_user.initial_step.blank?
        @mode = 'set_step'
      else
        @mode = 'edit'
      end
      gon.session_info = st.session_hash
      if current_user.admin
        respond_to do |format|
          format.html
          format.xlsx{
            @tables = [Step, Title, Chapter, Story, Synopsis, Character, ChapterCharacter, ChapterSynopsis]
          }
        end
      end
    else
      gon.session_info = st.session_hash
      @mode = 'show'
    end
  end

  # post method of index
  def sub_method
    upk_list = get_session.get_next_url_list params
    ret = edit_code(upk_list)
    session_token = SessionToken.find_by(session_id: session[:session_id])
    ret['session'] = session_token.session_hash
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

end
