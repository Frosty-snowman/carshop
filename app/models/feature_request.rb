class FeatureRequest < ApplicationRecord
  belongs_to :user, optional: true

  enum :status, { pending: 0, reviewed: 1, planned: 2, done: 3, declined: 4 }

  validates :name, :email, :title, :description, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :recent, -> { order(created_at: :desc) }

  def status_label
    {
      "pending" => "รอพิจารณา",
      "reviewed" => "อ่านแล้ว",
      "planned" => "วางแผนทำ",
      "done" => "ทำแล้ว",
      "declined" => "ไม่ทำ"
    }[status]
  end
end
