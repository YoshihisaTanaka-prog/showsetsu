class ApplicationController < ActionController::Base
    before_action :write_request_info

    def write_request_info
        logger.debug "\n=======================================\n"
        logger.debug "url >> " + request.original_url.to_s
        logger.debug "mthod >> " + request.method.to_s
        logger.debug "controller >> " + controller_name
        logger.debug "action >> " + action_name
        logger.debug "\n=======================================\n"
    end

    def after_sign_out_path_for(resource)
        new_user_session_path # ログアウト後に遷移するpathを設定
    end
    
    def set_new_token
    end

    def new_token table_name
    end

    def confirm_user_token
        if user_signed_in?
            unless current_user.token == params[:token]
                logger.debug 'token error (signed in)'
                redirect_to no_page_path
            end
        else
            unless session[:token] == params[:token]
                logger.debug 'token error'
                redirect_to no_page_path
            end
        end
    end


    before_action :configure_permitted_parameters, if: :devise_controller?
    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
        devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    end
end
