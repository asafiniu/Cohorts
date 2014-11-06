Rails.application.routes.draw do
  get 'orders/index'
  get 'cohorts/index'

  root to: 'cohorts#index'
end
