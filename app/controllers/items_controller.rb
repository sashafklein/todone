class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy, :archive]
  before_action :set_user, except: [:archive]

  respond_to :json

  def index
    @items = @user.items.from_last_three_days
    @item = @user.items.new
  end

  def edit
  end

  def create
    @items = @user.items.from_last_three_days
    @item = @user.items.new(item_params)

    if @item.save
      redirect_to user_items_path(@user), notice: 'Item was successfully created.'
    else
      render action: 'index'
    end
  end

  # PATCH/PUT /items/1
  def update
    if @item.update(item_params)
      redirect_to user_items_path(@user), notice: 'Item was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /items/1
  def destroy
    @item.destroy
    redirect_to items_url, notice: 'Item was successfully destroyed.'
  end

  def archive
    if @item.update_attribute(:archived, true)
      respond_with({success: true}, location: "")
    else
      respond_with({success: false}, location: "")
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    # Only allow a trusted parameter "white list" through.
    def item_params
      params.require(:item).permit(:description, :archived, :user_id)
    end
end
