require 'sinatra'
require 'mini_magick'

require 'rest-client'
require 'addressable/uri'


before do

  expires 36000, :public
end


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

  image.combine_options do |img|
    img.background 'white'
    img.alpha 'remove'
    img.alpha 'off'
    img.resize "#{params[:height]}x#{params[:width]}>"
  end

  image.format 'jpeg'
  image.strip

  content_type :jpeg
  image.to_blob
end