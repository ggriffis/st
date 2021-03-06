# == Schema Information
# Schema version: 20091117074908
#
# Table name: line_items
#
#  id           :integer(4)      not null, primary key
#  cents        :integer(4)
#  invoice_id   :integer(4)
#  from_user_id :integer(4)
#  to_user_id   :integer(4)
#  status       :string(255)
#  type         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Fee < LineItem
  validates_presence_of :from_user_id
  validates_presence_of :to_user_id
end
