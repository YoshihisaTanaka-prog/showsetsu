class Chapter < ApplicationRecord

    def title_data
        return Title.find_by(id: self.title_id)
    end

    def stories
        return Story.where(chapter_id: self.id).order(:order)
    end

    def synopses
        synopses = ChapterSynopsis.where(chapter_id: self.id).order(:order)
        ret = []
        synopses.each do |synopsis|
            synopsis = Synopsis.find_by(id: synopsis.synopsis_id)
            unless synopsis.blank?
                ret.push synopsis
            end
        end
        return ret
    end

    def characters
        characters = ChapterCharacter.where(chapter_id: self.id).order(:order)
        ret = []
        characters.each do |character|
            characters = Character.find_by(id: character.id)
            unless character.blank?
                ret.push character
            end
        end
        return ret
    end
    
end
