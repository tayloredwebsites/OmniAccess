class User < ApplicationRecord

  # Note: is not omniauthable.  we must login through devise, and use omniauth to get access to other services.
  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  devise :confirmable, :database_authenticatable, :lockable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  has_many :accesses

end
