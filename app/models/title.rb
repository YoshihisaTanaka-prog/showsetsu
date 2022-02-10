class Title < ApplicationRecord

    def chapters
        return Chapter.where(title_id: self.id).order(:order)
    end

    def storys
        ret = []
        self.chapters.each do |chapter|
            chapter.storys.each do |story|
                ret.push story
            end
        end
        return ret
    end

    def set_story_num
        sum = 1
        self.chapters.each do |chapter|
            chapter.first_story_num = sum
            chapter.save
            sum = sum + chapter.stories.length
        end
    end

end
