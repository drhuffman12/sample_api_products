##
# module ProductApi::Data
#
#   params:
#     _id:    String
#     name:   String
#     type:   String
#     length: Integer
#     width:  Integer
#     height: Integer
#     weight: Integer
#
#
# List Product(s):
#   params:
#     optional: _id, name, type, length, width, height, weight
#
#   e.g.: curl http://localhost:3000/api/v1/product_api_data.json
#   e.g.: curl http://localhost:3000/api/v1/product_api_data.json -X GET -d "name=widget&length=2"
#
#
# Create a new product:
#   params:
#     required: name, type, length, width, height, weight
#
#   e.g.: curl http://localhost:3000/api/v1/product_api_data.json -d "name=foo&type=bar&length=1&width=2&height=3&weight=4"
#
#
#
# Delete a product:
#   params:
#     required: _id
#
#   e.g.: curl -X DELETE http://localhost:3000/api/v1/product_api_data/5567cd64647268258e000000.json
#
#
# Update a product:
#
#   For the object of the given '_id', use the given value(s) for associated param key(s).
#
#   params:
#     required: _id
#     optional: name, type, length, width, height, weight
#
#   e.g.: curl -X PUT http://localhost:3000/api/v1/product_api_data/5567d7d2647268271b000000.json -d "name=widget&length=2"
#

module ProductApi

  class DuplicateKeysError < StandardError
  end

  class Data < Grape::API

    PARAM_KEYS = ['id', '_id', 'name', 'type', 'length', 'width', 'height', 'weight']

    resource :product_api_data do

      desc "List Product(s)"
      # parameter validation:
      params do
        optional :_id, type: String
        optional :name, type: String
        optional :type, type:String
        optional :length, type:Integer
        optional :width, type:Integer
        optional :height, type:Integer
        optional :weight, type:Integer
      end
      # list:
      get do
        if (PARAM_KEYS & params.keys).count == 0
          Product.all
        else
          filters = {}
          filters[:name] = params[:name] if params[:name]
          filters[:type] = params[:type] if params[:type]
          filters[:length] = { "$gte" => params[:length] } if params[:length]
          filters[:width] = { "$gte" => params[:width] } if params[:width]
          filters[:height] = { "$gte" => params[:height] } if params[:height]
          filters[:weight] = { "$gte" => params[:weight] } if params[:weight]
          prod = Product.order_by([[:length, :asc], [:width, :asc], [:height, :asc], [:weight, :asc]]).find_by(filters)
        end
      end

      desc "Create a new product"
      # parameter validation:
      params do
        requires :name, type: String
        requires :type, type:String
        requires :length, type:Integer
        requires :width, type:Integer
        requires :height, type:Integer
        requires :weight, type:Integer
      end
      # create:
      post do
        filters = {}
        filters[:name] = params[:name] if params[:name]
        filters[:type] = params[:type] if params[:type]
        prod = Product.find_by(filters)
        raise DuplicateKeysError, 'record already exists for specified keys' if prod
        Product.create!({
                            name:params[:name],
                            type:params[:type],
                            length:params[:length],
                            width:params[:width],
                            height:params[:height],
                            weight:params[:weight]
                        })
      end

      desc "Delete a product"
      params do
        requires :_id, type: String
      end
      delete ':_id' do
        Product.find(params[:_id]).destroy!
      end

      desc "Update a product"
      params do
        requires :_id, type: String
        optional :name, type: String
        optional :type, type:String
        optional :length, type:Integer
        optional :width, type:Integer
        optional :height, type:Integer
        optional :weight, type:Integer
      end
      put ':_id' do
        prod = Product.find(params[:_id])
        prod.update( { name:params[:name] } ) if params[:name]
        prod.update( { type:params[:type] } ) if params[:type]
        prod.update( { length:params[:length] } ) if params[:length]
        prod.update( { width:params[:width] } ) if params[:width]
        prod.update( { height:params[:height] } ) if params[:height]
        prod.update( { weight:params[:weight] } ) if params[:weight]
        prod.save
      end

    end

  end
end
