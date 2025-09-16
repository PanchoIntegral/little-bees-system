class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :role, :phone,
             :two_factor_enabled, :created_at, :updated_at,
             :full_name, :display_name

  def full_name
    object.full_name
  end

  def display_name
    object.display_name
  end
end