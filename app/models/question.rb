require_cubeless_engine_file :model, :question

class Question
  define_index do
    indexes :question 
  end
end