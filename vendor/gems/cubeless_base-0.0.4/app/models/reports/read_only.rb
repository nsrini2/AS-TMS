module Reports
  module ReadOnly
    # Prevent creation of new records and modification to existing records
    def readonly?
      readonly!
    end

    # Prevent objects from being destroyed
    def before_destroy
      raise ActiveRecord::ReadOnlyRecord
    end
  end
end