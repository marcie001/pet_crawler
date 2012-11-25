class User < ActiveRecord::Base
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :admin, :name

  has_many :settings_services
  has_many :pages
end
