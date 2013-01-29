class AuditController < ApplicationController

  allow_access_for :all => :shady_admin

  class Data
    attr_accessor :audits, :types, :actions, :attributes, :can_comment
  end

  class AuditQuery < ActiveForm
    attr_accessor :auditable_type, :auditable_id, :action, :attribute, :who_id
    def validate
      return unless who_id.blank?
      return if !auditable_type.blank? and (!auditable_id.blank? or (!action.blank? and !attribute.blank?) or (action=='delete'))
      errors.add_to_base("Must specify a type and (id, or action=delete, or action+field) or who_id")
    end
  end

  def query

    form, data = audit_form(params)

    @audit_partial = audit_partial(form,data)

    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page[:audit].replace @audit_partial
        end
      }
    end

  end


  private
  def audit_partial(form,data=nil)
    form,data = audit_form(form) if form.is_a?(Hash)
    { :partial => 'audit/audit', :locals => { :form => form, :data => data } }
  end

  def audit_form(params)

    form = AuditQuery.new(params[:query] || {})

    audit_id = form.auditable_id
    audit_type = form.auditable_type

    comment = params[:comment]
    if request.post?
      make_comment_on(audit_type,audit_id, comment) unless comment.blank? || audit_id.blank? || audit_type.blank?
    end

    # type lists
    data = Data.new
    data.types = list_by_sql('select auditable_type from audits group by auditable_type')
    data.actions = list_by_sql('select action from audits group by action')
    data.attributes = list_by_sql("select attribute from audits a join audit_values av on a.id=av.audit_id where auditable_type='#{audit_type}' group by attribute")

    # queries
    args = [:all]
    ModelUtil.add_joins!(args,"left join audit_values on audit_id=audits.id left join profiles p on p.id=audits.who_id")
    ModelUtil.add_selects!(args,"audits.*, p.screen_name as who_screen_name, audit_values.attribute as attribute, audit_values.value as value")
    ModelUtil.get_options!(args)[:order] = 'created_at desc, attribute asc'

    form.attributes.each do |key,value|
      ModelUtil.add_conditions!(args,["#{key}=?",value]) unless value.blank?
    end

    data.audits = form.valid? ? ActsAsAuditable::Audit.find(*args) : []

    data.can_comment = (!audit_type.blank? and !audit_id.blank? and data.audits.size>0)

    [form,data]

  end

  def make_comment_on(audit_type, audit_id, comment)
    audit = ActsAsAuditable::Audit.new_for(:comment,audit_type,audit_id)
    audit.save!
    audit.comment(comment)
  end

  def list_by_sql(sql)
    result = []
    ActsAsAuditable::Audit.connection.raw_connection.query(sql).each { |rs| result << rs[0] }
    result
  end

end