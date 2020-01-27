class Api::V1::Admin::ArticlesController < ApplicationController
  before_action :authenticate_user!

  def create
    authorize(current_user)
    article = current_user.articles.create(article_params)

    if article.persisted?
      render head: :ok
    else
      render json: { error: article.errors.full_messages }, status: 422
    end
  end

  def update
    authorize(current_user)
    
    if params[:article][:published] == "true"
      Article.update(params[:id], published: params[:article][:published], publisher_id: current_user.id)
      render head: :ok
    else 
      Article.update(params[:id], published: params[:article][:published], publisher_id: nil)
      render head: :ok
    end
  end

  def index
    authorize(current_user)

    articles = Article.where(published: false)
    render json: articles, each_serializer: Articles::IndexSerializer, role: current_user.role
  end

  private

  def article_params
    params.require(:article).permit(:title, :body)
  end
end