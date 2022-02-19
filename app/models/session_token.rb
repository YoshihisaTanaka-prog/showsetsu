class SessionToken < ApplicationRecord

    def test params
        logger.debug params
    end

    def delete
        kept_sessions = KeptSession.where(st_id: self.id)
        kept_sessions.each do |kept_session|
            kept_session.delete 
        end
        super.delete
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
        return KeptSession.where(st_id: self.id, is_enabled: true).order(:created_at)
    end

    def current_log
        return KeptSession.find_by(id: self.current_ks_id)
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

end
