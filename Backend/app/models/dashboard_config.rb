class DashboardConfig < ApplicationRecord
  belongs_to :user

  # Validations
  validates :layout_name, presence: true
  validates :config, presence: true
  validates :layout_name, uniqueness: { scope: :user_id }

  # JSON serialization for config - removed to handle manually

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_layout, ->(layout) { where(layout_name: layout) }

  # Default widget configuration
  DEFAULT_CONFIG = {
    widgets: [
      {
        id: 'today_revenue',
        type: 'stat_card',
        title: "Today's Revenue",
        position: { x: 0, y: 0, w: 3, h: 2 },
        settings: {
          icon: 'currency',
          color: 'blue',
          data_source: 'today_revenue'
        }
      },
      {
        id: 'monthly_revenue',
        type: 'stat_card',
        title: 'This Month',
        position: { x: 3, y: 0, w: 3, h: 2 },
        settings: {
          icon: 'trend_up',
          color: 'green',
          data_source: 'monthly_revenue'
        }
      },
      {
        id: 'average_sale',
        type: 'stat_card',
        title: 'Average Sale',
        position: { x: 6, y: 0, w: 3, h: 2 },
        settings: {
          icon: 'chart_bar',
          color: 'yellow',
          data_source: 'average_sale'
        }
      },
      {
        id: 'inventory_alerts',
        type: 'stat_card',
        title: 'Inventory Alerts',
        position: { x: 9, y: 0, w: 3, h: 2 },
        settings: {
          icon: 'warning',
          color: 'red',
          data_source: 'inventory_alerts'
        }
      },
      {
        id: 'payment_methods',
        type: 'payment_stats',
        title: 'Payment Methods',
        position: { x: 0, y: 2, w: 12, h: 4 },
        settings: {
          show_chart: true,
          period: 'month'
        }
      },
      {
        id: 'daily_sales',
        type: 'daily_breakdown',
        title: 'Daily Sales',
        position: { x: 0, y: 6, w: 6, h: 6 },
        settings: {
          days: 7,
          show_details: true
        }
      },
      {
        id: 'inventory_status',
        type: 'inventory_alerts',
        title: 'Inventory Status',
        position: { x: 6, y: 6, w: 6, h: 6 },
        settings: {
          limit: 5,
          show_out_of_stock: true,
          show_low_stock: true
        }
      }
    ],
    layout: {
      cols: 12,
      margin: [10, 10],
      container_padding: [15, 15]
    }
  }.freeze

  # Instance methods
  def parsed_config
    return DEFAULT_CONFIG if config.blank?

    if config.is_a?(String)
      JSON.parse(config)
    elsif config.is_a?(Hash)
      config
    else
      DEFAULT_CONFIG
    end
  rescue JSON::ParserError
    DEFAULT_CONFIG
  end

  def config=(value)
    if value.is_a?(Hash) || value.is_a?(Array)
      super(value.to_json)
    else
      super(value)
    end
  end

  def config
    raw_config = read_attribute(:config)
    return DEFAULT_CONFIG if raw_config.blank?

    if raw_config.is_a?(String)
      JSON.parse(raw_config)
    else
      raw_config
    end
  rescue JSON::ParserError
    DEFAULT_CONFIG
  end

  def update_widget(widget_id, updates)
    current_config = parsed_config.deep_dup
    widget_index = current_config['widgets'].find_index { |w| w['id'] == widget_id }

    if widget_index
      current_config['widgets'][widget_index].merge!(updates.stringify_keys)
      write_attribute(:config, current_config.to_json)
      save
    end
  end

  def add_widget(widget_data)
    current_config = parsed_config.deep_dup
    current_config['widgets'] << widget_data.stringify_keys
    write_attribute(:config, current_config.to_json)
    save
  end

  def remove_widget(widget_id)
    current_config = parsed_config.deep_dup
    current_config['widgets'].reject! { |w| w['id'] == widget_id }
    write_attribute(:config, current_config.to_json)
    save
  end

  def reset_to_default!
    write_attribute(:config, DEFAULT_CONFIG.to_json)
    save
  end

  # Class methods
  def self.for_user(user, layout_name = 'default')
    config = find_by(user: user, layout_name: layout_name)

    unless config
      config = new(
        user: user,
        layout_name: layout_name,
        active: true
      )
      config.write_attribute(:config, DEFAULT_CONFIG.to_json)
      config.save!
    end

    config
  end
end
