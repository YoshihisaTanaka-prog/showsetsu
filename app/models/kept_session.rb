class KeptSession < ApplicationRecord
    def session_hash
        ret = {}
        KeptSession.column_names.each do |column|
            unless ["created_at", "updated_at"].include?(column)
                ret[column] = self[column]
            end
        end
        return ret
    end
end
