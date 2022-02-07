class ChapterCharacter < ApplicationRecord
  belongs_to :chapter
  belongs_to :character
end
