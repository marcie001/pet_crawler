require './models/settings'
include Settings

class Settings::Service < ActiveRecord::Base
  belongs_to :user
  attr_accessible :authorization, :name
end
