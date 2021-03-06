class User < ActiveRecord::Base
  has_secure_password validations: false

  validates :name, presence: true

  validates :email, presence: true
  validates_uniqueness_of :email, case_sensitve: false

  validates :password, presence: true, length: {minimum: 5, maximum: 20}
  validates :password, presence: true, on: :create

  has_many :memberships
  has_many :groups, through: :memberships


  has_many :rsvps
  has_many :following_relationships, -> {order("created_at ASC")}, class_name: "Relationship", foreign_key: :follower_id
  has_many :leading_relationships, -> {order("created_at ASC")}, class_name: "Relationship", foreign_key: :leader_id

  has_many :comments, -> {order("created_at DESC")}, as: :commentable

  before_create :generate_random_slug

  mount_uploader :profile_img, ProfileImgUploader

  def is_member_of?(group)
    groups.where(id: group.id).length > 0 ? true : false
  end

  def is_going_to?(event)
    rsvp = rsvps.where(event_id: event.id).first
    rsvp && rsvp.going
  end

  def has_unrsvpd?(event)
    rsvp = rsvps.where(event_id: event.id).first
    rsvp && !rsvp.going
  end

  def generate_random_slug
    self.slug = SecureRandom.urlsafe_base64
  end

  def is_admin_of?(group)
    !memberships.where(group_id: group.id, role: "admin").empty?
  end

  def follow(other_user)
    Relationship.create(follower: current_user, leader: other_user) if current_user.can_follow?(other_user)
  end

  def follows?(other_user)
    following_relationships.map(&:leader).include?(other_user)
  end

  def can_follow?(other_user)
    !(self.follows?(other_user) || self == other_user)
  end

  def is_admin?
    role == "admin"
  end

  def can_modify_group?(group)
    return false unless group.class.to_s == "Group"
    self.is_admin? || self.is_admin_of?(group)
  end

  def can_modify_event?(event)
    return false unless event.class.to_s == "Event"
    self.is_admin? || self == event.creator
  end

  def generate_password_reset_token
    self.update_column(:password_reset_token, SecureRandom.hex(10))
  end

  def to_param
    self.slug
  end

  # returns events that the user is going to in the future
  def upcoming_rsvps
    events = []
    rsvps.each do |r|
      event = Event.find(r.event_id)
      events << event if event.date_time > DateTime.now.beginning_of_day
    end
    events.sort { |a,b| a.date_time <=> b.date_time }
    events.length > 0 ? events : false
  end

  def has_groups?
    groups.length > 0
  end


end