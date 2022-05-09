class ApplicationController < ActionController::Base
  def hello 
    render html: "helloo, world"
  end
end
