class SessionToken < ApplicationRecord

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
        ret['design_id'] = self.design
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

    def set_log save_hash
        if self.after_log.present?
            ks = self.after_log
        else
            ks = KeptSession.find_by(is_enabled: false)
            if ks.present?
                ks.is_enabled = true
                ks.st_id = self.id
                ks.save
            else
                ks = KeptSession.new
                ks.st_id = self.id
                ks.save
            end
        end
        KeptSession.column_names.each do |column|
            unless ["created_at", "updated_at", 'id', 'st_id', 'is_enabled'].include?(column)
                if save_hash.keys.include?(column)
                    ks[column] = save_hash[column]
                else
                    ks[column] = self.current_log[column] 
                end
            end
        end
        ks.save
        self.current_ks_id = ks.id
        self.save
    end

    def get_next_url_list params
        # ???????????????????????????????????????????????????
        set_session_keys
        if params[:before].present?
            self.go_before
        elsif params[:after].present?
            self.go_after
        elsif params[:mode].present?
            self.set_log ({mode: params[:mode]})
        elsif params[:uri].present?
            dummy = nil
        elsif params[:step_id].present? || params[:title_id].blank?
            if params[:step_id].present?
                sent_hash = {step: params[:step_id]} 
            else
                sent_hash = {step: -1}
            end
            KeptSession.column_names.each do |column|
                unless ["created_at", "updated_at", 'step', 'id', 'st_id', 'is_enabled'].include?(column)
                    sent_hash[column] = self.current_log[column]
                end
            end
            self.set_log sent_hash
        else
            sent_hash = {step: nil, title: params[:title_id]}
            if params[:chapter_id].blank?
                for i in 1..(@loop_session_keys.length - 1)
                    sent_hash[@loop_session_keys[i]] = nil
                end
            else
                sent_hash['chapter'] = params[:chapter_id]
                if (params[:story_id].present? && params[:synopsis_id].present?) || (params[:synopsis_id].present? && params[:character_id].present?) || (params[:character_id].present? && params[:story_id].present?)
                    for i in 2..(@loop_session_keys.length - 1)
                        sent_hash[@loop_session_keys[i]] = nil
                    end
                else
                    for i in 2..(@loop_session_keys.length - 1)
                        sent_hash[@loop_session_keys[i]] = params[@loop_session_keys[i]]
                    end
                end
            end
            self.set_log sent_hash
        end

        # ????????????URI?????????
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
