class ApplicationController < ActionController::Base
  # どのページからでもログイン関連のメソッドを呼べるようにする
  include SessionsHelper
end
