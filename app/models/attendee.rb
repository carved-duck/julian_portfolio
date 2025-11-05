class Attendee < ApplicationRecord
  belongs_to :event

  # Virtual attribute for the "Other" bringing option
  attr_accessor :bringing_other

  validates :name, presence: true
  validates :instagram_handle, presence: true
  validates :bringing, presence: true, if: :requires_bringing_field?
  # Message is optional

  scope :recent, -> { order(created_at: :desc) }

  private

  def requires_bringing_field?
    event&.requires_bringing_field?
  end
end
