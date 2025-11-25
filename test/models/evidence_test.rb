require "test_helper"

class EvidenceTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess
  
  # Disable fixtures for TDD
  def self.fixtures(*args); end

  test "should require dispute" do
    evidence = Evidence.new
    assert_not evidence.valid?
    assert_includes evidence.errors[:dispute], "must exist"
  end

  test "should allow attaching a file" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current)
    evidence = Evidence.create!(dispute: dispute, kind: "document")
    
    file = fixture_file_upload("test/fixtures/files/sample.txt", "text/plain")
    evidence.file.attach(file)
    
    assert evidence.file.attached?
  end
end

