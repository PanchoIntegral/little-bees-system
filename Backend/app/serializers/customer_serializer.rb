class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone, :address,
             :created_at, :updated_at, :full_name

  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end