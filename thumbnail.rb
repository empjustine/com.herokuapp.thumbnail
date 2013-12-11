require 'sinatra'
require 'mini_magick'

require 'rest-client'
require 'addressable/uri'


error RestClient::ResourceNotFound do

  # mask network errors as local not found
  raise Sinatra::NotFound
end


get '/:height/:width/*/*' do

  raw_url = params[:splat].join '://'
  url = Addressable::URI.parse(raw_url).normalize.to_str

  blob = RestClient.get url
  image = MiniMagick::Image.read blob

  halt 500 unless image.valid?

  image.resize "#{params[:height]}x#{params[:width]}>"
  image.background 'white'

  image.format 'jpeg'
  content_type :jpeg

  image.to_blob
end
