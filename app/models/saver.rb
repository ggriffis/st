# == Schema Information
# Schema version: 20091117074908
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(255)
#  email                     :string(255)
#  description               :text
#  avatar_id                 :integer(4)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  stylesheet                :text
#  view_count                :integer(4)      default(0)
#  vendor                    :boolean(1)
#  activation_code           :string(40)
#  activated_at              :datetime
#  state_id                  :integer(4)
#  metro_area_id             :integer(4)
#  login_slug                :string(255)
#  notify_comments           :boolean(1)      default(TRUE)
#  notify_friend_requests    :boolean(1)      default(TRUE)
#  notify_community_news     :boolean(1)      default(TRUE)
#  country_id                :integer(4)
#  featured_writer           :boolean(1)
#  last_login_at             :datetime
#  zip                       :string(255)
#  birthday                  :date
#  gender                    :string(255)
#  profile_public            :boolean(1)      default(TRUE)
#  activities_count          :integer(4)      default(0)
#  sb_posts_count            :integer(4)      default(0)
#  sb_last_seen_at           :datetime
#  role_id                   :integer(4)
#  type                      :string(255)
#  requested_match_cents     :integer(4)
#  asset_type_id             :integer(4)
#  organization_id           :integer(4)
#  first_name                :string(255)
#  last_name                 :string(255)
#  web_site_url              :string(255)
#  phone_number              :string(255)
#  notify_advocacy           :boolean(1)
#  short_description         :string(255)
#  featured_user             :boolean(1)      default(TRUE)
#

class Saver < Party
  belongs_to :organization
  has_many :all_donations_received, :class_name => 'Donation', :foreign_key => :to_user_id
  has_many :donations_received, :class_name => 'Donation', :foreign_key => :to_user_id,
           :conditions => "status = '#{LineItem::STATUS_PROCESSED}' OR status = '#{LineItem::STATUS_COMPLETED}'"
  has_many :donors, :through => :donations_received, :source => :from_user,
           :uniq => true, :conditions => "users.profile_public = 1"
  
  composed_of :requested_match,
              :class_name => "Money",
              :mapping => [%w(requested_match_cents cents)],
              :converter => Proc.new { |value| value.to_money }

  validates_presence_of :first_name

  validates_presence_of :organization
  validates_presence_of :asset_type

  def self.find_active(*args)
    with_scope(:find => {:conditions => ["requested_match_cents > 0 AND profile_public is true"]}) do
      find(*args)
    end
  end

  def self.find_random_active(*args)
    with_scope(:find => {:conditions => ["requested_match_cents > 0 AND profile_public is true"], :order => 'rand()'}) do
      find(*args)
    end
  end

  def self.find_random_featured(*args)
    with_scope(:find => {:conditions => ["requested_match_cents > 0 AND profile_public is true AND featured_user is true"], :order => 'rand()'}) do
      find(*args)
    end
  end

  def self.find_random_successful_savers(*args)
    with_scope(:find => {:conditions => ["requested_match_cents > 0 AND profile_public is true AND featured_user is true"], :order => 'rand()'}) do
      some_savers = find(*args)
      some_savers.select { | each_saver | each_saver.match_amount_left_cents <= 0 }
    end
  end

  def self.number_of_savers
    Saver.count
  end

  def is_successful_saver?
    return requested_match_cents <= 0
  end

  def match_percentage
    balance = matched_amount_cents
    if balance > 0
      return [((balance.to_f / requested_match_cents.to_f) * 100).round, 100].min
    else
      return 0
    end
  end

  def match_amount_left
    return Money.us_dollar(match_amount_left_cents)
  end

  def matched_amount
    return Money.us_dollar(matched_amount_cents)
  end

  def match_amount_left_cents
    aleft = requested_match_cents - matched_amount_cents
    if aleft < 0
      return 0
    else
      aleft
    end
  end

  def matched_amount_cents
    return donations_received.sum(:cents)
  end
end
