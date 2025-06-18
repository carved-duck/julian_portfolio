class Submission < ApplicationRecord
  validates :name, presence: true
  validates :message, presence: true
  validates :instagram_handle, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
