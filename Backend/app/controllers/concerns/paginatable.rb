module Paginatable
  extend ActiveSupport::Concern

  private

  # Main pagination method with optimized counting
  def paginate_collection(collection, params = {})
    # Extract and validate pagination parameters
    page = [params[:page].to_i, 1].max
    per_page = validate_per_page(params[:per_page])

    # Apply pagination
    paginated_collection = collection.limit(per_page).offset((page - 1) * per_page)

    # Optimized count - only count if we need total pages info
    # Use the same query scope for counting to maintain filter accuracy
    total_count = if needs_total_count?(params)
                    collection.count
                  else
                    nil
                  end

    {
      collection: paginated_collection,
      pagination_meta: build_pagination_meta(page, per_page, total_count, params)
    }
  end

  # Validate per_page parameter with reasonable limits
  def validate_per_page(per_page_param)
    per_page = per_page_param.to_i

    # Set default if invalid
    per_page = 20 if per_page <= 0

    # Set maximum limit to prevent performance issues
    [per_page, 100].min
  end

  # Determine if we need total count (expensive operation)
  def needs_total_count?(params)
    # Only calculate total count if explicitly requested or for first page
    params[:include_total] == 'true' || params[:page].blank? || params[:page].to_i == 1
  end

  # Build pagination metadata
  def build_pagination_meta(page, per_page, total_count, params)
    meta = {
      current_page: page,
      per_page: per_page,
      has_next_page: nil,
      has_prev_page: page > 1
    }

    if total_count
      total_pages = (total_count.to_f / per_page).ceil
      meta.merge!({
        total_count: total_count,
        total_pages: total_pages,
        has_next_page: page < total_pages,
        is_first_page: page == 1,
        is_last_page: page == total_pages
      })
    else
      # For performance, we can check if there's a next page without full count
      next_page_exists = check_next_page_exists(params[:base_query], page, per_page)
      meta[:has_next_page] = next_page_exists
    end

    meta
  end

  # Efficient check for next page existence without full count
  def check_next_page_exists(base_query, current_page, per_page)
    return false unless base_query

    next_page_offset = current_page * per_page
    base_query.limit(1).offset(next_page_offset).exists?
  end

  # Cursor-based pagination for high-performance scenarios
  def paginate_with_cursor(collection, cursor_params = {})
    cursor = cursor_params[:cursor]
    limit = validate_per_page(cursor_params[:limit] || 20)
    direction = cursor_params[:direction] || 'next'

    if cursor.present?
      # Parse cursor (assuming it's a timestamp or ID)
      cursor_value = decode_cursor(cursor)

      if direction == 'next'
        collection = collection.where("created_at > ?", cursor_value)
      else
        collection = collection.where("created_at < ?", cursor_value).reverse_order
      end
    end

    items = collection.limit(limit + 1).to_a
    has_more = items.size > limit
    items = items.first(limit) if has_more

    {
      items: items,
      cursor_meta: {
        has_more: has_more,
        next_cursor: has_more ? encode_cursor(items.last) : nil,
        prev_cursor: cursor
      }
    }
  end

  # Simple cursor encoding (can be enhanced with base64 or JWT)
  def encode_cursor(record)
    return nil unless record

    # Use created_at as cursor value
    record.created_at.to_i.to_s
  end

  def decode_cursor(cursor)
    Time.at(cursor.to_i)
  rescue
    Time.current
  end

  # Helper method for building filtered collections
  def build_filtered_collection(base_collection, filters)
    collection = base_collection

    filters.each do |key, value|
      next if value.blank?

      case key.to_sym
      when :search
        collection = apply_search_filter(collection, value)
      when :status
        collection = collection.where(status: value)
      when :category
        collection = collection.where(category: value)
      when :date_range
        collection = apply_date_range_filter(collection, value)
      when :user_id
        collection = collection.where(user_id: value)
      when :customer_id
        collection = collection.where(customer_id: value)
      end
    end

    collection
  end

  def apply_search_filter(collection, search_term)
    # Override in controllers for model-specific search
    collection
  end

  def apply_date_range_filter(collection, date_range)
    if date_range[:start_date].present? && date_range[:end_date].present?
      start_date = Date.parse(date_range[:start_date])
      end_date = Date.parse(date_range[:end_date])
      collection.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    else
      collection
    end
  end
end