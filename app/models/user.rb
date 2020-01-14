class User < ApplicationRecord
    attr_accessor :remember_token, :activation_token, :reset_token
    before_save :downcase_email
    before_create :create_activation_digest
    validates :name, presence: true, length: { maximum: 50 }  #validates is a method

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },  
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: { case_sensitive: false }

    has_secure_password #adds functionality: a password_digest attribute, a pair of virtual attributes (password & password_confirmation), an authenticate method that returns user when the password is correct. has_secure_password uses the bcrypt hash function (include in GEMFILE)
    
    has_many :microposts, dependent: :destroy
    has_many :active_relationships, class_name: "Relationship", 
                                    foreign_key: "follower_id", 
                                    # destroying a user should destroy that user's relationships
                                    dependent: :destroy
    has_many :passive_relationships, class_name: "Relationship", 
                                        foreign_key: "followed_id",
                                        dependent: :destroy
        #with code like 
        #    has_many :followeds, through: :active_relationships                  
        #Rails would see “followeds” and use the singular “followed", assembling a collection using #the followed_id relationships table. But user.followeds is rather awkward, so I will use #user.following instead. Rails allows default overriding, in this case using the source #parameter, which explicitly tells Rails that the source of the 'following' array is the set of 'followed' ids.
    has_many :following, through: :active_relationships, source: :followed 
    has_many :followers, through: :passive_relationships, source: :follower #source is optional here

    validates :password, length: { minimum: 6 }, presence: true, allow_nil: true

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
    def authenticated?(attribute, token)
        # metaprogramming is used with 'send'
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # Forgets a user by setting the remember_digest to nil
    def forget
        update_attribute(:remember_digest, nil)
    end

    # Activates an account
    def activate
        #   .self could have been used here but that is optional
        update_columns(activated: true, activated_at: Time.zone.now)
    end

    # Sends activation email
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # Sets the password reset attributes
    def create_reset_digest
        self.reset_token = User.new_token
        update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end

    # Sends password reset email
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # Returns true if a password reset has expired
    # Read < as “earlier than” - “Password reset sent earlier than two hours ago.”
    def password_reset_expired?
        reset_sent_at < 2.hours.ago 
    end

    # Defines a proto-feed
    # use of "?" ensures id is properly escaped before inclusion in SQL query preventing serious security hole called SQL injection
    def feed
        # A subselect is used here.
        # It arranges for all the set logic to be pushed into the db which is more efficient
        # This is the better alternative to the more cumbersome:
        #  Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id) which pulls all the followed users' ids into memory and creates an array
        # The more efficient subselect checks for the inclusion (what 'user_id IN following_ids') is doing but does it at the db level 
        following_ids = "SELECT followed_id FROM relationships
                        WHERE follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", following_ids: following_ids, user_id: id)
    end

    # the 'following' association is treated like an array (due to   has_many :following, through: :active_relationships, source: :followed) making this possible
    # the new relationship gets inserted into the relationships table
    def follow(other_user)
        following << other_user
    end

    def unfollow(other_user)
        following.delete(other_user)
    end

    def following?(other_user)
        following.include?(other_user)
    end



    private

        # converts email to all lower-case
        def downcase_email
            email.downcase!
        end

        # Creates and assigns the activation token and digest.
        def create_activation_digest
          self.activation_token  = User.new_token
          self.activation_digest = User.digest(activation_token)
        end

end
                