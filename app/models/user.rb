class User < ApplicationRecord
    #before_save { self.email = email.downcase }     # a callback method that's invoked at the stage before the object is saved. In the User model, the self keyword is optional on the right-hand side
    before_save { email.downcase! } #concise version of above
    validates :name, presence: true, length: { maximum: 50 }  #validates is a method
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },  
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: { case_sensitive: false }

    has_secure_password #adds functionality: a password_digest attribute, a pair of virtual attributes (password & password_confirmation), an authenticate method taht returns user when the password is correct. has_secure_password uses the bcrypt hash function (include in GEMFILE)
    validates :password, length: { minimum: 6 }, presence: true
end
 