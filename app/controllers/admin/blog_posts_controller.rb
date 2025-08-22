module Admin
  class BlogPostsController < Admin::BaseController
    before_action :set_blog_post, only: %i[show edit update destroy]

    # GET /admin/blog_posts or /admin/blog_posts.json
    def index
      @blog_posts = BlogPost.all
    end

    # GET /admin/blog_posts/1 or /admin/blog_posts/1.json
    def show
    end

    # GET /admin/blog_posts/new
    def new
      @blog_post = BlogPost.new
    end

    # GET /admin/blog_posts/1/edit
    def edit
    end

    # POST /admin/blog_posts or /admin/blog_posts.json
    def create
      @blog_post = BlogPost.new(blog_post_params)

      respond_to do |format|
        if @blog_post.save
          format.html { redirect_to admin_blog_post_path(@blog_post), notice: "Blog post was successfully created." }
          format.json { render :show, status: :created, location: @blog_post }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @blog_post.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/blog_posts/1 or /admin/blog_posts/1.json
    def update
      respond_to do |format|
        if @blog_post.update(blog_post_params)
          format.html { redirect_to admin_blog_post_path(@blog_post), notice: "Blog post was successfully updated." }
          format.json { render :show, status: :ok, location: @blog_post }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @blog_post.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /admin/blog_posts/1 or /admin/blog_posts/1.json
    def destroy
      @blog_post.destroy!

      respond_to do |format|
        format.html do
          redirect_to admin_blog_posts_path, status: :see_other, notice: "Blog post was successfully destroyed."
        end
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_blog_post
      # Try to find by slug first, then by id
      @blog_post = BlogPost.find_by(slug: params[:id]) || BlogPost.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def blog_post_params
      params.require(:blog_post).permit(:title, :body, :published_at, :slug)
    end
  end
end
