class Event < ApplicationRecord
  has_many :attendees, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true

  scope :active, -> { where(active: true) }

  def attendee_count
    attendees.count
  end
end
