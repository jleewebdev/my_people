class GroupsController < ApplicationController

  before_filter :require_user, only: [:new, :create, :update, :comment, :edit]
  before_filter :set_group, only: [:show, :update, :comment, :edit]

  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)

    @group.creator_id = current_user.id

    if set_city_and_state

      if @group.save
        flash[:success] = "Your group has been created."
        redirect_to group_path(@group)
      else
        flash.now[:danger] = "There was an error and your group was not created."
        render :new
      end
    else
      flash.now[:danger] = "Not a valid Zip code."
      render :new
    end
  end

  def show
    @comment = Comment.new
    @announcements = @group.announcements
  end

  def edit
    @announcement = Announcement.new
  end

  def update
    if @group.update(group_params)
      flash[:success] = "Post saved"
      redirect_to group_path(@group)
    else
      flash[:danger] = "There was an error and your Post was not saved"
      render :edit
    end
  end

  private

  def set_city_and_state
    address_info = ZipCodes.identify(@group.zip_code)
    if address_info
      @group.city = address_info[:city]
      @group.state = address_info[:state_name]
    else
      false
    end
  end

  def set_group
    @group = Group.find_by(slug: params[:id])
  end

  def group_params
    params.require(:group).permit!
  end

  def comment_params
    params.require(:comment).permit!
  end

end