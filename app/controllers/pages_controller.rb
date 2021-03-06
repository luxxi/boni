class PagesController < ApplicationController
  def home
    
  end

  def restaurants
    @restaurants = Restaurant.all
    @hash = Gmaps4rails.build_markers(@restaurants) do |restaurant, marker|
      marker.lat  restaurant.latitude
      marker.lng  restaurant.longitude
      marker.json({name: restaurant.name, address: restaurant.address, city: restaurant.city.name, price: restaurant.price_in_eur })
    end
    respond_to do |format|
      format.json { render json: @hash }
    end
  end

  def version
    respond_to do |format|
      format.json { render json: Version.first }
    end
  end
end
