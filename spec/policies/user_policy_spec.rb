require 'rails_helper'

# Requirement: Authorization restricts member write actions to 宮主 (master)
RSpec.describe UserPolicy do
  subject(:policy) { described_class.new(current_user, record) }

  let(:record) { build(:user) }

  describe "write actions (create/new/update/edit/destroy)" do
    context "when the signed-in user is a master (宮主)" do
      let(:current_user) { build(:user, :master) }

      it "permits every write action" do
        expect(policy.create?).to be(true)
        expect(policy.new?).to be(true)
        expect(policy.update?).to be(true)
        expect(policy.edit?).to be(true)
        expect(policy.destroy?).to be(true)
      end
    end

    %i[normal member volunteer president vice_master].each do |status|
      context "when the signed-in user's status is #{status}" do
        let(:current_user) { build(:user, status: status) }

        it "denies every write action" do
          expect(policy.create?).to be(false)
          expect(policy.new?).to be(false)
          expect(policy.update?).to be(false)
          expect(policy.edit?).to be(false)
          expect(policy.destroy?).to be(false)
        end
      end
    end
  end

  describe "read actions (index/show)" do
    %i[master normal member volunteer].each do |status|
      context "when the signed-in user's status is #{status}" do
        let(:current_user) { build(:user, status: status) }

        it "permits index and show" do
          expect(policy.index?).to be(true)
          expect(policy.show?).to be(true)
        end
      end
    end
  end
end
