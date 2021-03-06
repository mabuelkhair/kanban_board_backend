class User::CommentsController < ApplicationController
  before_action :authorize_as_admin
  before_action :set_list
  before_action :set_card
  before_action :set_comment, only: [:show, :update, :destroy]
  before_action :is_comment_owner, only: [:destroy, :update]
  before_action :is_list_member

  # GET /comments
  def index
    page_number = 0
    page_number = params[:page].to_i if params[:page] && params[:page].to_i > 0
    @comments = @card.comments.offset(page_number*5).limit(5)

    render json: @comments, each_serializer: CommentSerializer
  end

  # GET /comments/1
  def show
    render json: @comment, serializer: CommentSerializer
  end

  # POST /comments
  def create
    @comment =  @card.comments.new(comment_params)
    @comment.owner_id = @current_user['id']
    
    if @comment.save
      $redis.incr("card:#{@card.id}:comments")
      render json: @comment, status: :created, serializer: CommentSerializer
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(comment_params)
      render json: @comment, serializer: CommentSerializer
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  def destroy
    $redis.decr("card:#{@card.id}:comments")
    @comment.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end
    def set_card
      @card = @list.cards.find(params[:card_id])
    end

    def set_list
      @list = List.find(params[:list_id])
    end
    def is_comment_owner
      render json: { error: 'You do not have permission for this' }, status: 403 unless @comment.owner_id == @current_user['id'] 
    end
    def is_list_member
      @list.users.find(@current_user['id'])
    end

    # Only allow a trusted parameter "white list" through.
    def comment_params
      params.require(:comment).permit(:card_id, :comment_id, :list_id, :content)
    end
end
