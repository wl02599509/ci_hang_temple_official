# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlashComponent, type: :component do
  let(:no_flash) { {} }
  let(:notice_flash) { { notice: "Success message" } }
  let(:alert_flash) { { alert: "Error message" } }
  let(:component) { described_class.new(flash: flash) }

  describe "#render?" do
    context "when flash is present" do
      let(:flash) { notice_flash }

      it "renders the component" do
        expect(component.send(:render?)).to be_truthy
      end
    end

    context "when flash is empty" do
      let(:flash) { no_flash }

      it "does not render the component" do
        expect(component.send(:render?)).to be_falsy
      end
    end
  end

  describe "#flash_msg" do
    context "when flash type is notice" do
      let(:flash) { notice_flash }

      it "displays the flash message" do
        expect(component.flash_msg).to eq("Success message")
      end
    end

    context "when flash type is alert" do
      let(:flash) { alert_flash }

      it "displays the flash message" do
        expect(component.flash_msg).to eq("Error message")
      end
    end
  end

  describe "#flash_class" do
    context "when flash type is notice" do
      let(:flash) { notice_flash }

      it "returns the correct class" do
        expect(component.flash_class).to eq("bg-green-100 text-green-800 p-4 rounded-lg mb-4")
      end
    end

    context "when flash type is alert" do
      let(:flash) { alert_flash }

      it "returns the correct class" do
        expect(component.flash_class).to eq("bg-red-100 text-red-800 p-4 rounded-lg mb-4")
      end
    end
  end
end
