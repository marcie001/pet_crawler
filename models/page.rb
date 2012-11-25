class Page < ActiveRecord::Base
  belongs_to :user
  attr_accessible :tag0, :tag1, :tag2, :tag3, :tag4, :url
end
