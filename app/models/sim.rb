# == Schema Information
#
# Table name: vbooks
#
#  id         :bigint           not null, primary key
#  topic      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Sim < ApplicationRecord
  has_many  :messages, dependent: :destroy

  validates :topic, presence: true
end
