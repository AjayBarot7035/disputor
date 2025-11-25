require "test_helper"

class EvidencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "admin@example.com",
      password: "password123",
      role: :admin,
      time_zone: "UTC"
    )
    post sessions_url, params: { session: { email: @user.email, password: "password123" } }

    @charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    @dispute = Dispute.create!(
      charge: @charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: Time.current
    )
  end

  test "should create evidence with file" do
    file = fixture_file_upload("test/fixtures/files/sample.txt", "text/plain")

    assert_difference "Evidence.count", 1 do
      post dispute_evidences_path(@dispute), params: {
        evidence: {
          kind: "document",
          file: file,
          note: "Customer receipt"
        }
      }
    end

    assert_redirected_to dispute_path(@dispute)
    evidence = Evidence.last
    assert_equal "document", evidence.kind
    assert evidence.file.attached?
    assert_equal "Customer receipt", evidence.metadata["note"]
  end

  test "should create evidence without file" do
    assert_difference "Evidence.count", 1 do
      post dispute_evidences_path(@dispute), params: {
        evidence: {
          kind: "note",
          note: "Internal note"
        }
      }
    end

    assert_redirected_to dispute_path(@dispute)
    evidence = Evidence.last
    assert_equal "note", evidence.kind
    assert_equal "Internal note", evidence.metadata["note"]
  end

  test "should not allow read_only user to add evidence" do
    read_only_user = User.create!(
      email: "readonly@example.com",
      password: "password123",
      role: :read_only,
      time_zone: "UTC"
    )
    delete session_url(@user)
    post sessions_url, params: { session: { email: read_only_user.email, password: "password123" } }

    assert_no_difference "Evidence.count" do
      post dispute_evidences_path(@dispute), params: {
        evidence: {
          kind: "note",
          note: "Should not work"
        }
      }
    end

    assert_redirected_to dispute_path(@dispute)
    assert_equal "You do not have permission to add evidence", flash[:alert]
  end
end
