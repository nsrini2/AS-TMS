require_cubeless_engine_file :model, :user
require_de_engine_file :model, :user

class User
  include Notifications::User
end