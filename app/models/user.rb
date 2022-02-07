class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def steps
    return Step.where(user_id: self.id).order(:order)
  end

  def titles
    return Title.where(user_id: self.id)
  end

  def steps
    return Step.where(user_id: self.id).order(:order)
  end

  def initial_step
    if self.steps.blank?
      return nil
    else
      return self.steps.first
    end
  end

end
