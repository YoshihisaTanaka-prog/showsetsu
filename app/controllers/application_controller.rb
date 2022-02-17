class ApplicationController < ActionController::Base
    before_action :write_request_info
    protect_from_forgery except: [:index, :show, :new, :edit]

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
    
    def set_new_token session_id
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
        st = Sessiontoken.find_by(session_id: session_id)
        if se.blank?
            st = Sessiontoken.new
            st.token = new_token
            st.save
        else
            st.token = new_token
            st.save
        end
    end

    def edit_code(upk_list)
        require "net/http"
        order = []
        code_hash = {}
        upk_list.each do |upk|
            uri = URI.parse(root_url + upk[:uri])
            if upk[:uri].include?('/delete')
                parameters = upk[:params].merge({user_id: current_user.id, _method: 'DELETE'})
            else
                parameters = upk[:params].merge({user_id: current_user.id})
            end
            # parameters = upk[:params].merge({session_id: session[:session_id], authentication_token: params[:token]})
            # logger.debug parameters
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
