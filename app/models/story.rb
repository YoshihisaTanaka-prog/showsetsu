class Story < ApplicationRecord

    def chapter
        return Chapter.find_by(id: self.chapter_id)
    end

    def title_data
        return Title.find_by(id: self.chapter.title_data)
    end

end
