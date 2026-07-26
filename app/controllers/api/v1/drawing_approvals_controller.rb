module Api
  module V1
    class DrawingApprovalsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_drawing_approval, only: [:show, :update]

      def index
        @approvals = DrawingApproval.all.order(created_at: :desc)
        render json: @approvals, include: [:design_drawing, :drawing_version, :approver]
      end

      def show
        render json: @approval, include: [:design_drawing, :drawing_version, :approver]
      end

      def create
        @approval = DrawingApproval.new(drawing_approval_params)
        @approval.approver = current_user
        @approval.status = 'pending'

        if @approval.save
          render json: @approval, status: :created, location: @approval
        else
          render json: @approval.errors, status: :unprocessable_entity
        end
      end

      def update
        if @approval.update(drawing_approval_params)
          render json: @approval
        else
          render json: @approval.errors, status: :unprocessable_entity
        end
      end

      def approve
        @approval = DrawingApproval.find(params[:id])
        @approval.approve!(params[:comment])
        render json: @approval
      end

      def reject
        @approval = DrawingApproval.find(params[:id])
        @approval.reject!(params[:comment])
        render json: @approval
      end

      def pending
        @approvals = DrawingApproval.where(status: 'pending').order(created_at: :asc)
        render json: @approvals, include: [:design_drawing, :drawing_version]
      end

      private

      def set_drawing_approval
        @approval = DrawingApproval.find(params[:id])
      end

      def drawing_approval_params
        params.require(:drawing_approval).permit(:design_drawing_id, :drawing_version_id, :status, :comment)
      end
    end
  end
end
