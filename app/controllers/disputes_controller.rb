class DisputesController < ApplicationController
  before_action :set_dispute, only: [ :show, :update, :reopen ]

  def index
    @disputes = Dispute.includes(:charge).order(created_at: :desc)
  end

  def show
  end

  def update
    new_status = params[:dispute][:status]
    note = params[:dispute][:note]

    if @dispute.transition_to(new_status, actor: current_user, note: note)
      redirect_to @dispute, notice: "Dispute status updated successfully"
    else
      flash.now[:alert] = "Invalid status transition"
      render :show, status: :unprocessable_entity
    end
  end

  def reopen
    justification = params[:justification]

    if @dispute.reopen(actor: current_user, justification: justification)
      redirect_to @dispute, notice: "Dispute reopened successfully"
    else
      flash.now[:alert] = "Cannot reopen dispute from current status"
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_dispute
    @dispute = Dispute.find(params[:id])
  end
end
