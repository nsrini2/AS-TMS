class Abuse < ActiveRecord::Base

  belongs_to :abuseable, :polymorphic => true
  belongs_to :owner, :class_name => 'Profile', :foreign_key => "owner_id"
  belongs_to :remover, :class_name => 'Profile', :foreign_key => "remover_id"

  validates_presence_of :reason
  belongs_to :profile

  def self.find(*args)
    ModelUtil.add_includes!(args,:profile,:owner)
    super(*args)
  end

  def validate_on_create
    errors.add(:abuseable_id, "is already flagged." ) if remover_id.nil? && Abuse.exists?(['abuseable_type=? and abuseable_id=? and remover_id is null',abuseable_type,abuseable_id])
  end

  def after_create
    abuseable.audit_snapshot! if remover_id.nil?
  end

  def mark_removed(remover_id)
    self.remover_id = remover_id
    self.removed_at = Time.new
    self
  end
  
end
