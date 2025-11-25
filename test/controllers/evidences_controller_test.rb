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
end

