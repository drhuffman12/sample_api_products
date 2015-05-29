module ProductApi
  class Data < Grape::API

    resource :product_api_data do
      desc "List all Products"

      get do
        Product.all
      end

    end

  end
end