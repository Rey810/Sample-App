class Micropost < ApplicationRecord
  belongs_to :user
  #defines the order by which microposts are pulled from the database
  # -> is stabby lambda syntax
  default_scope -> { order(created_at: :desc) }
  # The way to tell CarrierWave (a gem) to associate the image with a model
  # the symbol represents the attribute. PictureUploader is the class name of the generated uploader
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  # call to a custom validation must be singular. i.e. validate NOT validates
  validate :picture_size

  private

    # Validates the size of an uploaded picture
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
