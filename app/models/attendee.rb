class Attendee < ApplicationRecord
  belongs_to :event

  validates :name, presence: true
  validates :instagram_handle, presence: true
  # Message is optional

  scope :recent, -> { order(created_at: :desc) }
end
