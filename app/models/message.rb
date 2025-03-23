# == Schema Information
#
# Table name: messages
#
#  id         :bigint           not null, primary key
#  body       :text
#  image_url  :string
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sim_id     :integer
#
class Message < ApplicationRecord
  belongs_to :sim

  validates :role, inclusion: { in: [ "system", "user", "assistant" ] }
  validates :role, presence: true
  validates :body, presence: true
end
