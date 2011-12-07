require 'active_record'

module ActsAsAuditable

  # abstract this out later
  def self.current_user_id
    user = AuthenticatedSystem.current_profile
    user.nil? ? nil : user.id
  end

  # dev only
  def self.truncate!
    Audit::Value.destroy_all
    Audit.destroy_all
  end

  module ActsMethods

    def acts_as_auditable(options={})
      acts_as_modified
      include InstanceMethods
      after_create :audit_after_create
      after_update :audit_after_update
      after_destroy :audit_after_destroy
      cattr_accessor :audit_config
      exclude_attributes = Set.new(['id','updated_at','created_at'])
      options[:exclude_attributes].each { |v| exclude_attributes << v.to_s } if options.member?(:exclude_attributes)
      self.audit_config = {
        :enabled => options.fetch(:enabled,true),
        :audit_unless_owner_attribute => options[:audit_unless_owner_attribute].to_s,
        :snapshot_on_first_audit => options.fetch(:snapshot_on_first_audit,true),
        :exclude_attributes => exclude_attributes,
        :exclude_events => Set.new(options.fetch(:exclude_events,[]))
      }
    end

    def find_from_audits(options={})

      ModelUtil.add_joins!(options,"left join audit_values on audit_id=audits.id left join profiles p on p.id=audits.who_id")
      ModelUtil.add_selects!(options,"audits.*, p.screen_name as who_screen_name, audit_values.attribute as attribute, audit_values.value as value")
      ModelUtil.add_conditions!(options,['auditable_type=?',self.to_s])

      filter_deleted = options.delete(:deleted_items)
      ModelUtil.add_conditions!(options,"auditable_id in (select auditable_id from audits where action='delete' group by auditable_id)") if filter_deleted #!O big temp table, no scoping
#      conditions_identify = options.delete(:conditions_identify)
#      Audit.with_scope(:find => { :conditions => conditions_identify }) do
#        ids = Audit.find(:all,options).collect { |a| a.auditable_id }
#        return [] if ids.size==0
#        ModelUtil.add_conditions!(options.merge(:select => 'auditable_id', :group => 'auditable_id'),"auditable_id in (#{ids.join(',')})")
#      end if conditions_identify

      options[:order] = 'auditable_id asc, id asc'

      results = []
      id_current = nil
      model = nil
      do_set_created = self.columns_hash.member?('created_at')
      Audit.find(:all,options).each do |a|
        if a.auditable_id!=id_current
          id_current = a.auditable_id
          # avoid partial records filtered by date ranges/etc -- lead with create/snapshot only
          model = nil
          next unless a.action=='create' or a.action=='snapshot'
          model = self.new
          model[:id] = id_current
          model.created_at = a.created_at if do_set_created #!H
          results << model
        end
        next if model.nil?

        if a.action=='delete'
          model['audit_deleted_by_id'] = a.who_id
          model['audit_deleted_by_screen_name'] = a.who_screen_name
          model['audit_deleted_at'] = a.created_at
        end

        next unless a.attribute
        column = model.column_for_attribute(a.attribute)
        next unless column
        model[a.attribute]=column.type_cast(a.value)
      end
      results.delete_if { |r| !r.attributes.member?('audit_deleted_by_id') } if filter_deleted
      results.each { |r| r.freeze }
      results
    end
  end

  module InstanceMethods

    @@_audit_snapshot_actions = Set.new([:update,:delete])

    def audit?
      return false unless audit_config[:enabled]
      if audit_config[:audit_unless_owner_attribute]
        id = ActsAsAuditable.current_user_id
        return false if id.nil? || id==attributes[audit_config[:audit_unless_owner_attribute]]
      end
      true
    end

    def audit_snapshot!
      audit!(:snapshot) { |a| a.add_values(attributes.merge(modified_attributes_loaded_values),audit_config[:exclude_attributes]) }
    end

    def audit_comment!(comment)
      audit!(:comment) { |a| a.comment(comment) }
    end

    def audit!(action,&block)
      return if audit_config[:exclude_events].member?(action)
      audit_snapshot! if audit_config[:snapshot_on_first_audit] and
        @@_audit_snapshot_actions.member?(action) and
        Audit.count_by_sql(['select count(1) from audits where auditable_type=? and auditable_id=? limit 1',self.class.name,self.id])==0
      a = Audit.new_for_auditable(action,self)
      a.save!
      yield a unless block.nil?
      a
    end

    private
    def audit_after_create
      audit!(:create) { |a| a.add_values(attributes,audit_config[:exclude_attributes]) } if audit?
    end

    def audit_after_update
      audit!(:update) { |a| a.add_values(modified_attributes_values,audit_config[:exclude_attributes]) } if modified? and audit?
    end

    def audit_after_destroy
      audit!(:delete) if audit?
    end

  end

  class Audit < ActiveRecord::Base

    has_many :values, :class_name => 'Value'

    # not wild about this new_for or *args patterns... revisit

    def self.new_for(*args)
      new { |a|
        a.action, a.auditable_type, a.auditable_id = args
        a.who_id = ActsAsAuditable.current_user_id
      }
    end

    def self.new_for_auditable(action,auditable)
      self.new_for(action,auditable.class.name,auditable.id)
    end

    def action=(v)
      super(v.to_s)
    end

    def add_value(attribute,value)
      self.values << Audit::Value.new_for(attribute,value)
    end

    @@empty_set = Set.new
    def add_values(attr_values,exclude_attributes=@@empty_set)
      attr_values.each_pair { |attr,value| add_value(attr,value) unless exclude_attributes.member?(attr) }
    end

    def add_reference(model)
      self.values << Audit::Value.new_for_reference(model)
    end

    def comment(comment)
      self.values << Audit::Value.new_for('[comment]',comment)
    end

    def find(*args)
      super(*args)
    end

    class Value < ActiveRecord::Base

      set_table_name 'audit_values'
      belongs_to :audit

      def self.new_for(*args)
        # MM2: attribute is now a private method in Rails 2.2.3. Using ["attribute"] instead
        # new { |a| a.attribute, a.value = args }
        # new { |a| a["attribute"], a.value = args }        
    
        # Now that doesn't even work in Rails 3
        # Changing the column name to attribute_name to use from here on out
        new { |a| a.attribute_name, a.value = args }
      end

      def self.new_for_reference(model)
        new_for(">#{model.class.name}",model.id)
      end

      def value=(v)
        write_attribute('value',v.nil? ? nil : v.to_s)
      end

    end

  end

  ActiveRecord::Base.extend ActsMethods

end
