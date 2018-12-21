module Api
  module V1
    class ConversationsController < ApiController
      after_action :delete_conversation_notifications, only: :index

      def index
        render json: conversations.all, status: :ok
      end

      def show
        if conversation.is_deleted?(current_user)
          render json: { data: 'Η συνομιλία έχει διαγραφεί' }, status: :unprocessable_entity
          return
        end
        mark_as_read

        render json: messages, status: :created
      end

      def destroy
        conversation.mark_as_deleted(current_user)
        render json: conversation, status: :created
      end

      def delete_all
        conversations.delete_all
        render json: { message: 'Οι συνομηλίες διαγράφηκαν' }, status: :ok
      end

      private

      def delete_conversation_notifications
        current_user.conversation_notifications.destroy_all
      end

      def mark_as_read
        return unless conversation.is_unread?(current_user)
        conversation.mark_as_read(current_user)
      end

      def messages
        conversation.receipts_for(current_user).map(&:message)
      end

      def conversation
        @conversation ||= conversations.show(params[:id])
      end

      def conversations
        @conversations ||= Services::Conversations.new(current_user)
      end
    end
  end
end
