class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def save_new_order
    self.save
    self.order = self.id
    self.save
  end

  def render_json
    ret = {id: self.id, type: self.class.name.downcase}
    return ret.to_json
  end

  def create_chapter_conection selected_chapter_string_list, all_chapter_list
    case self.class.name.downcase
    when 'character'
      table = ChapterCharacter
      column = 'character_id'
    when 'synopsis'
      table = ChapterSynopsis
      column = 'synopsis_id'
    else
      return
    end
    selected_chapter_id_list = selected_chapter_string_list.map{ |str| str.to_i }
    all_chapter_id_list = all_chapter_list.map{ |chapter| chapter.id }
    if input_list.length == 0
      all_chapter_id_list.each do |id|
        chap_table = table.find_by("chapter_id = ? and  ? = ?", id, column, self.id)
        chap_table.delete
      end
      self.delete
    else
      all_chapter_id_list.each do |id|
        chap_table = table.find_by("chapter_id = ? and  ? = ?", id, column, self.id)
        if selected_chapter_id_list.include?(id)
          # 選択されたチャプターのIDの場合
         if chap_table.blank?
           chap_table = table.new
           chap_table.chapter_id = id
           chap_table[column.to_sym] = self.id
           chap_table.is_effective = true
           chap_table.save_new_order
         elsif !chap_table.is_effective
           chap_table.is_effective = true
           chap_table.save
         end
        else
          # 選択されていないチャプターのIDの場合
          unless chap_table.blank?
            if chap_table.is_effective
              chap_table.is_effective = false
              chap_table.save
            end
          end
        end
      end
    end
  end

end
