class Attendee < ApplicationRecord
  belongs_to :event

  # Answers to "What will you be bringing?" that aren't food categories, so they get no count.
  BRINGING_NOT_SURE = 'Not sure yet'.freeze
  BRINGING_OTHER = 'Other'.freeze

  # What the visitor typed after picking "Other". It replaces `bringing` on save.
  attr_accessor :bringing_other

  validates :name, presence: true
  validates :instagram_handle, presence: true
  validates :bringing, presence: { message: "Pick one so we can plan the table. \"#{BRINGING_NOT_SURE}\" is fine." },
                       if: :requires_bringing_field?
  validates :bringing, inclusion: { in: ->(_) { Event::BRINGING_CATEGORIES + [BRINGING_NOT_SURE, BRINGING_OTHER] },
                                    message: 'is not one of the choices' },
                       on: :create, allow_blank: true, if: :requires_bringing_field?
  validates :bringing_other, presence: true, on: :create, if: :other_picked?
  # Message is optional

  before_save :use_other_text, if: :other_picked?

  scope :recent, -> { order(created_at: :desc) }

  def bringing_known?
    bringing.present? && bringing != BRINGING_NOT_SURE
  end

  private

  def requires_bringing_field?
    event&.requires_bringing_field?
  end

  def other_picked?
    requires_bringing_field? && bringing == BRINGING_OTHER
  end

  def use_other_text
    self.bringing = bringing_other.strip if bringing_other.present?
  end
end
