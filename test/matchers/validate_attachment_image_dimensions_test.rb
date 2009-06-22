require 'test/helper'

class ValidateAttachmentContentTypeMatcherTest < Test::Unit::TestCase
  context "validate_attachment_image_dimensions" do
    setup do
      reset_table("dummies") do |d|
        d.string :avatar_file_name
      end
      @dummy_class = reset_class "Dummy"
      @dummy_class.has_attached_file :avatar
      @matcher     = self.class.validate_attachment_image_dimensions(:avatar).
                       allowing(:width => 100, :height => 100).
                       rejecting(:width => 50, :height => 50)
    end

    should "reject a class with no validation" do
      assert_rejects @matcher, @dummy_class
    end

    should "reject a class with a validation that doesn't match" do
      @dummy_class.validate_attachment_image_dimensions :avatar, :height => 50, :width => 50
      assert_rejects @matcher, @dummy_class
    end

    should "accept a class with a validation" do
      @dummy_class.validate_attachment_image_dimensions :avatar, :height => 100, :width => 100
      assert_accepts @matcher, @dummy_class
    end
  end
end
