class ApplicationController < ActionController::Base
    before_action :write_request_info
    protect_from_forgery except: [:index, :show, :new, :edit]

    def set_session_keys
      @loop_session_keys = ['title_id','chapter_id','story_id','synopsis_id','character_id']
      @non_loop_session_keys = ['design_id', 'step_id', 'mode_id']
    end

    def write_request_info
        logger.debug "\n=======================================\n"
        logger.debug "url >> " + request.original_url.to_s
        logger.debug "mthod >> " + request.method.to_s
        logger.debug "params >>"
        params.each do |key, value|
            logger.debug "#{key} : #{value}"
        end
        logger.debug request.referer
        logger.debug "\n=======================================\n"
    end

    def after_sign_out_path_for(resource)
        new_user_session_path # ログアウト後に遷移するpathを設定
    end

    def get_session
      if user_signed_in?
        st = SessionToken.find_by(user_id: current_user.id)
      else
        st = SessionToken.find_by(session_id: session[:session_id], is_enabled: true)
      end
  
      if st.present?
        st.session_id = session[:session_id] if user_signed_in?
        st.set_token
      else
        st = SessionToken.find_by(is_enabled: false)
        if st.present?
          st.is_enabled = true
        else
          st = SessionToken.new
        end
        st.user_id = current_user.id if user_signed_in?
        st.session_id = session[:session_id]
        ks = KeptSession.find_by(is_enabled: false)
        if ks.present?
            ks.is_enabled = true
        else
            ks = KeptSession.new
        end
        ks.st_id = st.id
        ks.save
        st.current_ks_id = ks.id
        st.set_token
      end
      return st
    end

    def edit_code(upk_list)
        st = get_session
        require "net/http"
        order = []
        code_hash = {}
        upk_list.each do |upk|
            uri = URI.parse(root_url + upk[:uri])
            if upk[:uri].include?('/delete')
                if st.present?
                    parameters = upk[:params].merge({user_id: current_user.id, _method: 'DELETE', session_id: st.session_id, token: st.token})
                else
                    parameters = upk[:params].merge({user_id: current_user.id, _method: 'DELETE'}) 
                end
            else
                if st.present?
                    parameters = upk[:params].merge({user_id: current_user.id, session_id: st.session_id, token: st.token})
                else
                    parameters = upk[:params].merge({user_id: current_user.id}) 
                end
            end
            res = Net::HTTP.post_form(uri, parameters)
            if res.code == '200'
                logger.debug res.body
                order.push(upk[:key])
                code_hash[upk[:key]] = res.body.force_encoding("UTF-8")
            end
        end
        return {code: code_hash, order: order}
    end

    before_action :configure_permitted_parameters, if: :devise_controller?
    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
        devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    end
end
