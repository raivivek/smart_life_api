ActiveAdmin.register Product do
  # menu parent: "商品相关"
  actions :all
  permit_params :title, :price, :count, :detail, :sort, product_cover_attributes: [:id, :desc, :photo, :_destroy], product_detail_attributes: [:id, :desc, :photo, :_destroy]
  
  filter :title
  # filter :state, emun: true

  # scope_to do 
  #   Product.sale_off
  # end
  # scope :for_sale, default: true
  
  controller do 
    #更改默认搜索范围
    #index仅显示 正在销售
    def scoped_collection
      Product.for_sale
    end
    
    def destroy
      @product = Product.find(params[:id])
      @product.sale_off!
      @product.count = 0 #防止下架商品加入购物车
      @product.save
      redirect_to :back
    end

    def update
      @product = Product.find(params[:id])
      @product.product_sort = ProductSort.title_is(sort_params[:sort]).try(:first)
      @product.update_attributes(product_params)
      redirect_to admin_product_path(@product)

    end

    private
      def product_params
        params.require(:product).permit(:title, :price, :count, :detail, product_cover_attributes: [:id, :desc, :photo, :_destroy], product_detail_attributes: [:id, :desc, :photo, :_destroy])
      end

      def sort_params
        params.require(:product).permit(:sort)
      end
  end

  index do 

    selectable_column
    # id_column
    # column :state
    column :title
    column :price
    column :count
    column :detail
    column :sort
    # column :created_at
    # column :updated_at
    column :product_cover do |product|
      link_to(image_tag(product.product_cover.photo.url(:mini)), product.product_cover.photo.url, target: "_blank") if product.product_cover
    end

    column :product_detail do |product|
      link_to(image_tag(product.product_detail.photo.url(:mini)), product.product_detail.photo.url(:s750), target: "_blank") if product.product_detail
    end

    column :product_banners do |product|
      link_to "查看轮播图", admin_product_product_banners_path(product)
    end
   
    actions 
    # column :state do |product|
    #   "已下架" if product.state == 'sale_off'
    # end
  end

  form html: {multipart: true} do |f|
    f.inputs do 
      f.input :title
      f.input :price,  min: 0
      f.input :count
      f.input :detail

      f.input :sort, as: :select, collection: ProductSort.all.collect(&:title)
      f.fields_for :product_cover, for: [:product_cover, f.object.product_cover || f.object.build_product_cover] do |cf|
        image = cf.object
        cf.input :photo, as: :file, label: "商品主图", hint: (image.try(:photo).blank?) \
          ? cf.template.content_tag(:span, "还未上传图片文件")
          : cf.template.link_to(image_tag(image.photo.url(:medium)), image.photo.url(:s750), target: "_blank")
      end

      f.fields_for :product_detail, for: [:product_detail, f.object.product_detail || f.object.build_product_detail] do |cf|
        image = cf.object
        cf.input :photo, as: :file, label: "商品详情图", hint: (image.try(:photo).blank?) \
          ? cf.template.content_tag(:span, "还未上传图片文件")
          : cf.template.link_to(image_tag(image.photo.url(:medium)), image.photo.url(:s750), target: "_blank")
      end

    end

    f.actions
  end

  show do |product|
    attributes_table do
      row :title
      row :price
      row :count
      row :detail
      row :sort
      row :product_sort_id
      # row :created_at
      # row :updated_at
      row :product_cover do
        if product.product_cover
          link_to(image_tag(product.product_cover.photo.url(:medium)), product.product_cover.photo.url, target: "_blank")
        end
      end

      row :product_detail do
        if product.product_detail
          link_to(image_tag(product.product_detail.photo.url(:medium)), product.product_detail.photo.url(:s750), target: "_blank")
        end
      end

      row :product_banners do
        link_to "商品轮播图", admin_product_product_banners_path(product)
      end

      row " " do
        link_to "返回商品列表", admin_products_path
      end

      row " " do
        link_to "修改商品信息", edit_admin_product_path(product)
      end

    end
  end

end