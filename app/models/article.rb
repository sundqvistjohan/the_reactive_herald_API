class Article < ApplicationRecord
  validates_presence_of :title, :body
  
  belongs_to :journalist, class_name: 'User'
  belongs_to :publisher, class_name: 'User', optional: true

  after_update :check_published_status

  def check_published_status
    if self.publisher_id_before_last_save != nil
      self.publisher = nil
      self.save
    end
  end
end