class Role
  attr_reader :key, :id

  private
  @@roles = Set.new
  @@role_id_map = {}
  def initialize(key, id)
    @key = key
    @id = id
    @@roles << self
    @@role_id_map[id] = self
  end
  public

  CubelessAdmin = Role.new(:cubeless_admin, 0)
  ReportAdmin = Role.new(:report_admin, 1)
  ContentAdmin = Role.new(:content_admin, 2)
  ShadyAdmin = Role.new(:shady_admin, 3)
  UserAdmin = Role.new(:user_admin, 4)
  DirectMember = Role.new(:direct_member, 5)
  SponsorMember = Role.new(:sponsor_member, 6)
  AwardsAdmin = Role.new(:awards_admin, 7)
  SponsorAdmin = Role.new(:sponsor_admin, 8)
  
  def self.roles
    @@roles
  end

  def to_s
    {@key => @id}
  end

  def self.find(role_id)
    @@role_id_map[role_id]
  end

  def self.find_all(*role_ids)
    role_ids.collect { |x| @@role_id_map[x] }
  end

end

module CubelessAuthorization

  def self.included(base)
    base.extend(ClassMethods)
    base.helper_method(:show_content_for)
    base.helper_method(:hide_content_for)
    InstanceMethods.__send__ :append_features, base
  end

  module InstanceMethods

    def deny_access_for(*roles)
      respond_not_authorized if roles.any?{|x| current_profile.role_keys.member?(x)}
    end

  end

  module ClassMethods

    def allow_access_for(options={})
      access_control(false,create_action_role_access_hash(options))
    end

    def deny_access_for(options={})
       access_control(true,create_action_role_access_hash(options), options[:when])
    end

    def access_control(should_deny, action_role_access_hash, _when=nil)
      before_filter do |c|
        request_action = c.action_name.to_sym
        action_roles = Array(action_role_access_hash[request_action] || action_role_access_hash[:all])
        unless(action_roles.empty?)
          do_filter = (_when ? _when.call(c) : true)
          if do_filter
            has_role = action_roles.any?{|x| c.current_profile && c.current_profile.role_keys.member?(x)}
            c.respond_not_authorized if has_role == should_deny
          end
        end
      end
    end

    def create_action_role_access_hash(a={})
      a.inject({})do |access_hash, (actions, roles)|
        Array(actions).each{|action| access_hash[action] = roles}
        access_hash
      end
    end
  end

  def show_content_for(*r)
    yield if current_profile.has_role?(*r)
  end

  def hide_content_for(*r)
    yield unless current_profile.has_role?(*r)
  end

  module RoleAccess
    def self.included(base)
      Role.roles.each do |role|
        base.named_scope "exclude_#{role.key.to_s}s".to_sym, :conditions => "profiles.roles not like '%#{role.id}%'"
      end
      Role.roles.each do |role|
        base.named_scope "include_#{role.key.to_s}s".to_sym, :conditions => "profiles.roles like '%#{role.id}%'"
      end
    end

    def roles    
      roles = (super || "") unless @roles_set_cache
      unless @roles_set_cache
        if roles.blank?
          @roles_set_cache = Set.new
        else
          @roles_set_cache = Role.find_all(*roles.split(',').map(&:to_i)).to_set.freeze
        end
      end
      @roles_set_cache
    end

    def role_keys
      @role_key_set_cache ||= roles.collect(&:key)
    end

    def roles=(new_roles)
      @roles_set_cache = nil
      self[:roles] = new_roles.collect(&:id).join(',')
    end

    def add_roles(*r)
      self.roles = roles.dup.merge(r)
    end

    def remove_roles(*r)
      self.roles = roles.dup.subtract(r)
    end

    def has_role?(*r)
      r.any?{|x| roles.dup.member?(x)}
    end
    
    def is_content_admin?()
       has_role?(Role::ContentAdmin)
    end
  end
end