require "spec_helper"

describe GroupsController do

  describe "GET index" do
    it "sets @groups" do
      group1 = Fabricate(:group)
      group2 = Fabricate(:group)
      get :index
      expect(assigns(:groups)).to match_array([group1, group2])
    end

  end

  describe "GET new" do

    it "sets @group" do
      sign_in
      get :new
      expect(assigns(:group)).to be_instance_of(Group)
    end

    it_behaves_like "requires sign in" do
      let(:action) { get :new }
    end
  end

  describe "POST create" do
    context "with valid inputs" do
      
      let(:group_params) { Fabricate.attributes_for(:group)}
      let(:alice) { Fabricate(:user) }

      before do
        sign_in(alice)
        post :create, group: group_params
      end

      it "redirects to the new group page" do
        expect(response).to redirect_to group_path(Group.first)
      end

      it "creates the group" do
        expect(Group.count).to eq(1)
      end

      it "sets the flash message" do
        expect(flash[:success]).to be_present
      end

      it "sets the creator to the current_user" do
        expect(Group.first.creator_id).to eq(alice.id)
      end

    end

    context "with invalid inputs" do

      before do
        sign_in
        post :create, group: { name: "1" }
      end

      it "renders the :new template" do
        expect(response).to render_template :new
      end

      it "sets the flash message" do
        expect(flash[:danger]).to be_present
      end

      it "doesn't create the group" do
        expect(Group.count).to eq(0)
      end

    end

    it_behaves_like "requires sign in" do
      let(:action) { post :create, group: {name: "1"} }
    end

  end

  describe "PATCH update" do
    let(:group) { Fabricate(:group, name: "old_group") }

    it "updates attributes" do
      sign_in
      put :update, id: group.slug, group: { name: "new group" }
      expect(Group.first.name).to eq("new group")
    end

    it_behaves_like "requires sign in" do
      let(:action) { put :update, id: group.slug, group: { name: "new group" } }
    end
  end


end