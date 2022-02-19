class SessionToken < ApplicationRecord

    loop_session_keys = ['title','chapter','story','synopsis','character']
    non_loop_session_keys = ['design', 'step', 'mode']

    def remove_session
        kept_sessions = KeptSession.where(st_id: self.id)
        kept_sessions.each do |kept_session|
            kept_session.is_enabled = false
            kept_sessions.save
        end
        self.is_enabled = false
        self.save
    end

    def set_token
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
        self.token = new_token
        self.save
    end

    def logs
        c_log = self.current_log
        after_ks  = KeptSession.where(st_id: self.id, is_enabled: true).where('updated_at > ?', c_log.updated_at).where.not(id: self.current_ks_id).order(:updated_at)
        before_ks = KeptSession.where(st_id: self.id, is_enabled: true).where('updated_at < ?', c_log.updated_at).where.not(id: self.current_ks_id).order(:updated_at)
        ret = []
        unless before_ks.blank?
            ret.push(before_ks.last)
        end
        ret.push(self.current_log)
        unless after_ks.blank?
            ret.push(after_ks)
        end
        ret.flatten!
        return ret
    end

    def current_log
        return KeptSession.find_by(id: self.current_ks_id)
    end

    def session_hash
        c_log = KeptSession.find_by(id: self.current_ks_id)
        ret = c_log.session_hash
        ret['design'] = self.design
        return ret
    end

    def before_log
        kept_sessions = self.logs
        if kept_sessions.blank?
            return nil
        elsif kept_sessions.first.id == self.current_ks_id
            return nil
        else
            kept_sessions.each_with_index do |kept_session, index|
                if kept_session.id == self.current_ks_id
                    return kept_sessions[index - 1]
                end
            end
        end
    end

    def go_before
        self.current_ks_id = self.before_log.id if self.before_log.present?
    end

    def after_log
        kept_sessions = self.logs
        if kept_sessions.blank?
            return nil
        elsif kept_sessions.last.id == self.current_ks_id
            return nil
        else
            kept_sessions.each_with_index do |kept_session, index|
                if kept_session.id == self.current_ks_id
                    return kept_sessions[index + 1]
                end
            end
        end
    end

    def go_after
        self.current_ks_id = self.after_log.id if self.after_log.present?
    end

    def set_log(save_hash, mode)
        if self.after_log.present?
            ks = self.after_log
        else
            ks = KeptSession.find_by(is_enabled: false)
            if ks.present?
                ks.is_enabled = true
                ks.st_id = self.id
            else
                ks = KeptSession.new
                ks.st_id = self.id
            end
        end
        if save_hash.present?
            save_hash.each do |key, value|
                ks[key] = value
            end
            ks.mode = self.current_log.mode
        else
            KeptSession.column_names.each do |column|
                unless ["created_at", "updated_at"].include?(column)
                    ks[column] = self.current_log[column]
                end
            end
            ks.mode = mode
        end
        ks.save
        self.current_ks_id = ks.id
        self.save
    end

    def change_mode mode
        cks = self.current_log
        self.set_log({}, mode)
    end

    def get_next_url_list params
        # 送られてきたパラムのバリデーション
        loop_session_keys = Grobal::loop_session_keys
        if params[:before].present?
            self.go_before
        elsif params[:after].present?
            self.go_after
        elsif params[:mode].present?
            self.change_mode params[:mode]
        elsif params[:step].present? || params[:title].blank?
            sent_hash = {step: params[:step]}
            KeptSession.column_names.each do |column|
                unless ["created_at", "updated_at", 'step'].include?(column)
                    sent_hash[column] = self.current_log[column]
                end
            end
            self.set_log sent_hash
        else
            sent_hash = {step: nil, title: params[:title]}
            if params[:chapter].blank?
                for i in 1..(loop_session_keys.length - 1)
                    sent_hash[loop_session_keys[i]] = nil
                end
            else
                sent_hash['chapter'] = params[:chapter]
                if (params[:story].present? && params[:synopsis].present?) || (params[:synopsis].present? && params[:character].present?) || (params[:character].present? && params[:story].present?)
                    for i in 2..(loop_session_keys.length - 1)
                        sent_hash[loop_session_keys[i]] = nil
                    end
                else
                    for i in 2..(loop_session_keys.length - 1)
                        sent_hash[loop_session_keys[i]] = params[loop_session_keys[i]]
                    end
                end
            end
            self.set_log sent_hash
        end

        # 読み取るURIの取得
        logger.debug "\n================================================================\n\nget_next_url_list, params >>\n"
        params.each do |key, value|
          logger.debug key + ' >> ' + value.to_s
        end
        logger.debug "\n================================================================\n"

        current_log = self.current_log
        if params[:uri].present?
          if params[:uri].include?('/')
            return [{uri: params[:uri], params: {}, key: params[:key]}]
          else
            main_parameter = {authenticity_token: params[:authenticity_token]}
            model_name = params[:uri].to_s
            num = 3
            string_parameter_list = params[params[:uri]].to_s.split('"')
            while num < string_parameter_list.length
              main_parameter[model_name + '[' + (string_parameter_list[num-2]) + ']'] = string_parameter_list[num]
              num = num + 4
            end
           if current_log[params[:uri]].nil?
            return [{uri: params[:uri].pluralize, params: main_parameter, key: params[:key]}]
           elsif current_log[params[:uri]] < 1
            return [{uri: params[:uri].pluralize, params: main_parameter, key: params[:key]}]
           else
            main_parameter['_method'] = 'PATCH'
            return [{uri: params[:uri].pluralize + '/' + current_log[params[:uri]].to_s + '/update', params: main_parameter, key: params[:key]}]
           end
          end
        elsif current_log[:step].present?
          if current_log[:step] == -1
            return [{uri: 'steps/index', params: {controller: 'steps', action: 'index'}, key: 'body-main'}]
          elsif current_log[:step] == 0
            return [{uri: 'steps/new', params: {controller: 'steps', action: 'index'}, key: 'body-main'}]
          else
            return [{uri: 'steps/' + current_log[:step] + '/' + current_log[:mode], params: {controller: 'steps', action: 'index'}, key: 'body-main'}]
          end
        elsif current_log[:title].present?
          if current_log[:chapter].present?
            if current_log[:story].present?
              return [
                {uri: 'titles/' + current_log[:title] + '/' + current_log[:mode], params: {}, key: ''},
                {uri: 'chapters/' + current_log[:chapter] + '/' + current_log[:mode], params: {}, key: ''},
                {uri: 'stories/' + current_log[:story] + '/' + current_log[:mode], params: {}, key: ''}
              ]
            elsif current_log[:synopsis].present?
              return [
                {uri: 'titles/' + current_log[:title] + '/' + current_log[:mode], params: {}, key: ''},
                {uri: 'chapters/' + current_log[:chapter] + '/' + current_log[:mode], params: {}, key: ''},
                {uri: 'synopsis/' + current_log[:synopsis] + '/' + current_log[:mode], params: {}, key: ''}
              ]
            elsif current_log[:character].present?
              return [
                {uri: 'titles/' + current_log[:title] + '/' + current_log[:mode], params: {}, key: ''}, 
                {uri: 'chapters/' + current_log[:chapter] + '/' + current_log[:mode], params: {}, key: ''},
                {uri: 'character/' + current_log[:character] + '/' + current_log[:mode], params: {}, key: ''}
              ]
            else
              return [
                {uri: 'titles/' + current_log[:title] + '/' + current_log[:mode], params: {}, key: ''},
                {uri: 'chapters/' + current_log[:chapter] + '/' + current_log[:mode], params: {}, key: ''}
              ]
            end
          else
            return [{uri: 'titles/' + current_log[:title] + '/' + current_log[:mode], params: {}, key: ''}]
          end
        else
          return [{uri: 'titles/index', params: {}, key: ''}]
        end
    end

end
