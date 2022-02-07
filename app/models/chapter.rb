class Chapter < ApplicationRecord

    def storys
        return Story.where(user_id: self.id).order(:order)
    end

    def synopses
    end

    def characters
    end
    
end
