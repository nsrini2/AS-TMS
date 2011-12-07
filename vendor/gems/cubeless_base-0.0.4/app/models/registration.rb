class Registration < ActiveForm
  attr_accessor :fields
  
  def initialize(*)
    @fields = {}
    super
  end
  
  # Ensure none of the fields are empty
  def validate
    @fields.each_pair do |k,v|
      if v.nil? || !v.is_a?(Hash) || (v.is_a?(Hash) && v['required'] && v['value'].to_s.blank? )
        label = (v.is_a?(Hash) && v['label'] ? v['label'].to_s.downcase.gsub(" ", "_") : "Registration Field ##{k}")
        errors.add(label, "can't be blank")
      end
    end
  end
  
  def method_missing(method_name, *args)
    # Here we check for SiteRegistrationFields with an id of the missing method name
    # If found, we either get or set, depending on the method call
    if method_name.to_s.last == "="
      reader_method_name = method_name.to_s.chop
      label_name = reader_method_name.to_s.downcase.gsub("_", " ")
      
      if field = SiteRegistrationField.find_by_label(label_name)
        @fields[field.id.to_s] = { 'label' => field.label, 
                                   'value' => args[0], 
                                   'required' => field.required, 
                                   'id' => field.id, 
                                   'site_profile_field_id' => field.site_profile_field_id,
                                   'site_profile_field_question' => (field.site_profile_field ? field.site_profile_field.question : "") }
      else
        super
      end
    else
      begin
        if field = SiteRegistrationField.find_by_label(method_name.to_s.downcase.gsub("_", " ")) || 
                    SiteRegistrationField.find_by_label(method_name.to_s.downcase.gsub("_before_type_cast","").gsub("_", " ")) # MM2: This happens in forms sometimes
          @fields[field.id.to_s]['value'] if @fields[field.id.to_s]
        else
          super
        end
      rescue
        super
      end
    end
  end
  
end