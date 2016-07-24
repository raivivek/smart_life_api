require "acceptance_helper"

resource "购物相关接口" do
  header "Accept", "application/json"

  describe '商品的相关接口' do
    get 'products' do
      parameter :page, "页码", required: false
      parameter :per_page, "每页个数", required: false
      
      let(:page) { 1 }
      let(:per_page) { 10 }

      before do
        @products = create_list(:product, 3)
      end

      example "查看商品列表" do
        do_request
        puts response_body
        expect(status).to eq 200
      end
    end

    get 'products/:id' do
      before do
        @product = create(:product)
      end
      let(:id) { @product.id }

      example "查看指定商品详情" do
        do_request
        puts response_body
        expect(status).to eq 200
      end
      
    end  
  end

  describe '购物车的相关接口' do
    user_attrs = FactoryGirl.attributes_for(:user)

    header "X-User-Token", user_attrs[:authentication_token]
    header "X-User-Phone", user_attrs[:phone]

    before do
      @products = create_list(:product, 3)
      @user = create(:user)
    end

    post 'cart_items' do
      parameter :product_id, "产品的id", require: true, scope: :cart_item
      parameter :count, "产品的数量", require: true, scope: :cart_item

      let(:product_id) { @products.first.id }
      let(:count) { 2 }

      example "增加购物车一个项目" do
        do_request
        puts response_body
        expect(status).to eq 201 
      end
    end

    get 'cart_items' do
      parameter :page, "页码", required: false
      parameter :per_page, "每页个数", required: false
      
      let(:page) { 1 }
      let(:per_page) { 10 }

      before do
        @cart_items = create_list(:cart_item, 3, user: @user, product: @products.first)
      end

      example "查看用户的购物车列表" do
        do_request
        puts response_body
        expect(status).to eq 200
      end
    end

    get 'cart_items/:id' do
      before do
        @cart_item = create(:cart_item, user: @user, product: @products.first)
      end

      let(:id) { @cart_item.id }

      example "查看购物车单项详情" do
        do_request
        puts response_body
        expect(status).to eq(200)
      end
    end

    put 'cart_items/:id' do
      before do
        @cart_item = create(:cart_item, user: @user, product: @products.first)
      end

      parameter :count, "产品的数量", require: true, scope: :cart_item

      let(:id) { @cart_item.id }
      let(:count) { 2 }

      example "修改购物车的数量成功" do
        do_request
        puts response_body
        expect(status).to eq(204)
      end
    end

    put 'cart_items/:id' do
      before do
        @cart_item = create(:cart_item, user: @user, product: @products.first)
      end

      parameter :count, "产品的数量", require: true, scope: :cart_item

      let(:id) { @cart_item.id }
      let(:count) { -1 }

      example "修改购物车的数量失败（购买的产品数量小于等于0）" do
        do_request
        puts response_body
        expect(status).to eq(422)
      end
    end

    delete 'cart_items/:id' do
      before do
        @cart_item = create(:cart_item, user: @user, product: @products.first)
      end

      let(:id) { @cart_item.id }

      example "删除（取消）购物车的物品" do
        do_request
        puts response_body
        expect(status).to eq(204)
      end
    end

    post 'cart_items/pay' do
      before do
        @cart_items = create_list(:cart_item, 3, user: @user, product: @products.first)
      end

      parameter :cart_item_ids, "需要支付的购物清单列表", require: true, scope: :cart_item

      let(:cart_item_ids) { @cart_items.map(&:id) }

      example "支付购物列表成功" do
        do_request
        puts response_body
        expect(status).to eq 201
      end
    end


  end
end