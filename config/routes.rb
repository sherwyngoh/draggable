Rails.application.routes.draw do
  get 'week_view/index'
  root 'welcome#angular'
  get '/orgchart'  => 'welcome#index'
  get '/scheduler' => 'welcome#scheduler'
  get '/day_view'  => 'welcome#day_view'
  get '/week_view' => 'week_view#index'
  post '/week_view_manager' => 'week_view#manager'
  post '/common_shifts' => 'week_view#common_shifts'

end
