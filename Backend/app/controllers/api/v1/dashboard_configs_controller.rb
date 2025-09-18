class Api::V1::DashboardConfigsController < Api::BaseController
  before_action :set_dashboard_config, only: [:show, :update, :destroy]

  def index
    @configs = current_user.dashboard_configs.active

    render json: {
      configs: @configs.as_json(only: [:id, :layout_name, :active, :created_at, :updated_at]),
      current_config: DashboardConfig.for_user(current_user).parsed_config
    }
  end

  def show
    render json: {
      config: @dashboard_config.as_json(
        only: [:id, :layout_name, :active, :created_at, :updated_at]
      ),
      parsed_config: @dashboard_config.parsed_config
    }
  end

  def create
    @dashboard_config = current_user.dashboard_configs.build(dashboard_config_params)

    if @dashboard_config.save
      render json: {
        config: @dashboard_config.as_json(
          only: [:id, :layout_name, :active, :created_at, :updated_at]
        ),
        parsed_config: @dashboard_config.parsed_config
      }, status: :created
    else
      render json: { errors: @dashboard_config.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @dashboard_config.update(dashboard_config_params)
      render json: {
        config: @dashboard_config.as_json(
          only: [:id, :layout_name, :active, :created_at, :updated_at]
        ),
        parsed_config: @dashboard_config.parsed_config
      }
    else
      render json: { errors: @dashboard_config.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @dashboard_config.destroy
    render json: { message: 'Dashboard configuration deleted successfully' }
  end

  # Custom actions
  def current
    config = DashboardConfig.for_user(current_user, params[:layout_name] || 'default')
    render json: {
      config: config.as_json(
        only: [:id, :layout_name, :active, :created_at, :updated_at]
      ),
      parsed_config: config.parsed_config
    }
  end

  def update_widget
    config = DashboardConfig.for_user(current_user, params[:layout_name] || 'default')

    if config.update_widget(params[:widget_id], params[:widget_data])
      render json: {
        config: config.as_json(
          only: [:id, :layout_name, :active, :created_at, :updated_at]
        ),
        parsed_config: config.parsed_config
      }
    else
      render json: { errors: config.errors }, status: :unprocessable_entity
    end
  end

  def add_widget
    config = DashboardConfig.for_user(current_user, params[:layout_name] || 'default')

    if config.add_widget(params[:widget_data])
      render json: {
        config: config.as_json(
          only: [:id, :layout_name, :active, :created_at, :updated_at]
        ),
        parsed_config: config.parsed_config
      }
    else
      render json: { errors: config.errors }, status: :unprocessable_entity
    end
  end

  def remove_widget
    config = DashboardConfig.for_user(current_user, params[:layout_name] || 'default')

    if config.remove_widget(params[:widget_id])
      render json: {
        config: config.as_json(
          only: [:id, :layout_name, :active, :created_at, :updated_at]
        ),
        parsed_config: config.parsed_config
      }
    else
      render json: { errors: config.errors }, status: :unprocessable_entity
    end
  end

  def reset_default
    config = DashboardConfig.for_user(current_user, params[:layout_name] || 'default')

    if config.reset_to_default!
      render json: {
        config: config.as_json(
          only: [:id, :layout_name, :active, :created_at, :updated_at]
        ),
        parsed_config: config.parsed_config
      }
    else
      render json: { errors: config.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_dashboard_config
    @dashboard_config = current_user.dashboard_configs.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Dashboard configuration not found' }, status: :not_found
  end

  def dashboard_config_params
    params.require(:dashboard_config).permit(:layout_name, :active, :config)
  end
end
