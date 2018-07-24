module Api
  module V1
    class RegistrationsController < ::Devise::RegistrationsController
      skip_before_action :authenticate_scope!
      skip_before_action :doorkeeper_authorize!, only: :create

      def update
        self.resource = current_user

        if resource.respond_to?(:unconfirmed_email)
          prev_unconfirmed_email = resource.unconfirmed_email
        end

        resource_updated = resource.update(account_update_params)
        yield resource if block_given?
        if resource_updated
          if is_flashing_format?
            flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
              :update_needs_confirmation : :updated
              set_flash_message :notice, flash_key
          end
          bypass_sign_in resource, scope: resource_name
          respond_with resource
        else
          clean_up_passwords resource
          set_minimum_password_length
          respond_with resource
        end
      end

      private

      def current_user
        @current_user ||= current_resource_owner
      end

      def current_resource_owner
        User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end

      def sign_up_params
        params.require(:user).permit(allow_params)
      end

      def update_resource(resource, params)
        resource.update_without_password(params)
      end

      def account_update_params
        params.require(:user).permit(allow_params)
      end

      def allow_params
        [
          :username, :email, :password, :password_confirmation,
          user_detail_attributes: %i[
            state gender age profile_picture
          ]
        ]
      end
    end
  end
end
