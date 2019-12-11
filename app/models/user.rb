class User < ApplicationRecord
    attr_accessor :remember_token
    #before_save { self.email = email.downcase }     # a callback method that's invoked at the stage before the object is saved. In the User model, the self keyword is optional on the right-hand side
    before_save { email.downcase! } #concise version of above
    validates :name, presence: true, length: { maximum: 50 }  #validates is a method
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },  
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: { case_sensitive: false }

    has_secure_password #adds functionality: a password_digest attribute, a pair of virtual attributes (password & password_confirmation), an authenticate method that returns user when the password is correct. has_secure_password uses the bcrypt hash function (include in GEMFILE)
    validates :password, length: { minimum: 6 }, presence: true

    # Returns the hash digest of the given string
    #THis is done so that a user fixture for a valid user can be created in users.yml
    def self.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token.
    def self.new_token
        SecureRandom.urlsafe_base64
    end

    # Below creates a new remember token, and updates the remember digest in the db with the result of User.digest
    def remember
        # Without self., the assignment would create a local variable which isn't wanted. Using self. ensures the assignment sets the user's remember_token attribute
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Returns true if the given token matches the digest
    def authenticated?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end

    # Forgets a user by setting the remember_digest to nil
    def forget
        update_attribute(:remember_digest, nil)
    end
end
                