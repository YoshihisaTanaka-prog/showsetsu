class KeptSession < ApplicationRecord
    def session_hash
        ret = {}
        KeptSession.column_names.each do |column|
            unless ["created_at", "updated_at", 'id', 'st_id', 'is_enabled'].include?(column)
                ret[column + '_id'] = self[column]
            end
        end
        return ret
    end
end
