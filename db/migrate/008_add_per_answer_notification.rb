class AddPerAnswerNotification < ActiveRecord::Migration
    def self.up
      add_column :questions, :per_answer_notification, :boolean, :default => 0
    end

    def self.down
      remove_column :questions, :per_answer_notification
    end
end
