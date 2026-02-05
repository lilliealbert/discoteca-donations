class Volunteers::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  private

  def configure_sign_in_params
    params[:volunteer] ||= {}
    params[:volunteer][:remember_me] = "1"
  end
end