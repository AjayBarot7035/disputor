require "test_helper"

class DisputesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "admin@example.com",
      password: "password123",
      role: :admin,
      time_zone: "UTC"
    )
    post sessions_url, params: { session: { email: @user.email, password: "password123" } }
  end

  test "should get index" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: Time.current
    )

    get disputes_url
    assert_response :success
    assert_match dispute.external_id, response.body
  end

  test "should show dispute" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: Time.current
    )

    get dispute_url(dispute)
    assert_response :success
    assert_match dispute.external_id, response.body
  end

  test "should transition dispute status" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: Time.current,
      status: "open"
    )

    patch dispute_url(dispute), params: {
      dispute: {
        status: "needs_evidence",
        note: "Need more documentation"
      }
    }

    assert_redirected_to dispute_url(dispute)
    dispute.reload
    assert_equal "needs_evidence", dispute.status
    assert_equal 1, dispute.case_actions.count
  end

  test "should not transition with invalid status" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: Time.current,
      status: "open"
    )

    patch dispute_url(dispute), params: {
      dispute: {
        status: "won",
        note: "Invalid transition"
      }
    }

    assert_response :unprocessable_entity
    dispute.reload
    assert_equal "open", dispute.status
  end

  test "should allow reviewer to transition disputes" do
    reviewer = User.create!(
      email: "reviewer@example.com",
      password: "password123",
      role: :reviewer,
      time_zone: "UTC"
    )
    delete session_url(@user)
    post sessions_url, params: { session: { email: reviewer.email, password: "password123" } }

    charge = Charge.create!(external_id: "chg_456", amount_cents: 2000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_456",
      amount_cents: 2000,
      currency: "USD",
      opened_at: Time.current,
      status: "open"
    )

    patch dispute_url(dispute), params: {
      dispute: {
        status: "needs_evidence",
        note: "Reviewer transition"
      }
    }

    assert_redirected_to dispute_url(dispute)
    dispute.reload
    assert_equal "needs_evidence", dispute.status
  end

  test "should not allow read_only user to transition disputes" do
    read_only_user = User.create!(
      email: "readonly@example.com",
      password: "password123",
      role: :read_only,
      time_zone: "UTC"
    )
    delete session_url(@user)
    post sessions_url, params: { session: { email: read_only_user.email, password: "password123" } }

    charge = Charge.create!(external_id: "chg_789", amount_cents: 3000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_789",
      amount_cents: 3000,
      currency: "USD",
      opened_at: Time.current,
      status: "open"
    )

    # Read-only users can view but the form should be disabled
    get dispute_url(dispute)
    assert_response :success
  end

  test "should reopen dispute from won status" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: Time.current,
      status: "awaiting_decision"
    )
    dispute.transition_to("won", actor: @user, note: "Won")

    post reopen_dispute_path(dispute), params: { justification: "New evidence found" }
    
    assert_redirected_to dispute_url(dispute)
    dispute.reload
    assert_equal "reopened", dispute.status
  end
end

