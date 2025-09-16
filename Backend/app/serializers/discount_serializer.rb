class DiscountSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :discount_type, :discount_value,
             :minimum_amount, :active, :starts_at, :ends_at,
             :created_at, :updated_at, :is_valid_now

  def is_valid_now
    return false unless object.active?
    return true if object.starts_at.nil? && object.ends_at.nil?

    now = Time.current
    starts_valid = object.starts_at.nil? || object.starts_at <= now
    ends_valid = object.ends_at.nil? || object.ends_at >= now

    starts_valid && ends_valid
  end
end