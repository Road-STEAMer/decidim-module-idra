# frozen_string_literal: true

require "spec_helper"

module Decidim::Idra::Admin
  describe Permissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:organization) { create :organization }
    let(:context) do
      {
        current_organization: organization
      }
    end
    let(:action) do
      { scope: :admin, action: :read, subject: :idra }
    end
    let(:permission_action) { Decidim::PermissionAction.new(**action) }

    context "when user is admin" do
      let(:user) { create :user, :admin, organization: organization }

      it { is_expected.to be_truthy }

      context "when scope is not admin" do
        let(:action) do
          { scope: :foo, action: :read, subject: :idra }
        end

        it_behaves_like "permission is not set"
      end
    end

    context "when user is not admin" do
      let(:user) { create :user, organization: organization }

      it_behaves_like "permission is not set"
    end
  end
end
