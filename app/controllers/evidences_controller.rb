class EvidencesController < ApplicationController
  before_action :set_dispute
  before_action :require_edit_permission

  def create
    @evidence = @dispute.evidences.build(evidence_params)
    @evidence.metadata = { note: params[:evidence][:note] } if params[:evidence][:note].present?

    if @evidence.save
      redirect_to @dispute, notice: "Evidence added successfully"
    else
      flash.now[:alert] = "Failed to add evidence"
      render "disputes/show", status: :unprocessable_entity
    end
  end

  private

  def set_dispute
    @dispute = Dispute.find(params[:dispute_id])
  end

  def evidence_params
    params.require(:evidence).permit(:kind, :file)
  end

  def require_edit_permission
    unless current_user.can_edit?
      redirect_to @dispute, alert: "You do not have permission to add evidence"
    end
  end
end
