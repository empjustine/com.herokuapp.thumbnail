require 'sinatra'
require 'mini_magick'
require 'rest-client'


before do

  expires 36000, :public
end


error RestClient::ResourceNotFound do

  # mask network errors as local not found
  raise Sinatra::NotFound
end

get '/:height/:width/*/*' do

  url = params[:splat].join '://'

  blob = RestClient.get url
  image = MiniMagick::Image.read blob

  halt 500 unless image.valid?

  image.resize "#{params[:height]}x#{params[:width]}>"
  image.format 'jpeg'
  image.strip

  content_type :jpeg

  image.to_blob
end