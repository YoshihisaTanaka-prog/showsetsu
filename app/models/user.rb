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

  def initial_step
    if self.steps.blank?
      return nil
    else
      return self.steps.first
    end
  end

  def set_token
    new_token = ''
    for i in 0..254
      r = rand 61
     if r < 10
      new_token = new_token + r.to_s
     elsif r < 36
      new_token = new_token + (r + 55).chr
     else
      new_token = new_token + (r + 61).chr
     end
    end
    self.token = new_token
    self.save
  end

  def session_hash
    return {title: self.title, chapter: self.chapter, story: self.story, synopsis: self.synopsis, character: self.character, design: self.design, token: self.token, step: self.steps.length}
  end

end
