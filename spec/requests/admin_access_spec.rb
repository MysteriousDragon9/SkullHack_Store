require "rails_helper"

RSpec.describe "Admin access", type: :request do
  let(:user)  { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe "GET /admin" do
    context "when user is not an admin" do
      before { sign_in user }

      it "redirects to root with access denied message" do
        get admin_root_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied.")
        follow_redirect!
        expect(response.body).not_to include("Admin dashboard")
      end
    end

    context "when user is an admin" do
      before { sign_in admin }

      it "renders the admin dashboard" do
        get admin_root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Admin dashboard")
      end
    end

    context "when user is not signed in" do
      it "redirects to login page" do
        get admin_root_path
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be_nil # Devise usually sets no flash here
      end
    end
  end
end
