class EvidencesController < ApplicationController
  before_action :set_dispute

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
end

