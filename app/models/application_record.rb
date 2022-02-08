class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def set_token
  end

  def save_new_order
    self.save
    self.order = self.id
    self.save
  end

end
