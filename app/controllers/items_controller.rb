class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_user

  def index
    @items = @user.items
  end

  def show
  end

  # ItemsController.permits(:description)
  def new
    @item = @user.items.new
  end

  def edit
  end

  def create
    @item = @user.items.new(item_params)

    if @item.save
      redirect_to user_items_path(@user), notice: 'Item was successfully created.'
    else
      render action: 'new'
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
