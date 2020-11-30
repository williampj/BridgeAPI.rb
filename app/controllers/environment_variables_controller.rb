# frozen_string_literal: true

class EnvironmentVariablesController < ApplicationController
  before_action :authorize_request
  before_action :set_environment_variable

  def destroy
    @environment_variable.destroy
    render_message
  end

  protected

  def set_environment_variable
    @environment_variable = EnvironmentVariable.includes(:bridge)
                                               .find_by(id: params[:id], "bridges.user_id": @current_user.id)

    render_message status: :unprocessable_entity unless @environment_variable
  end
end
