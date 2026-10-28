Rails.application.routes.draw do
  root "courses#index"

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :courses, only: %i[index show] do
    post :enroll, on: :member

    resources :course_sessions, only: :show do
      get :otp, on: :member          # -> { otp, playbackInfo } for this session's video
      resource :progress, only: :update
    end
  end

  namespace :admin do
    root "courses#index"
    resources :courses, except: :show do
      resources :course_sessions, except: %i[index show] do
        post :refresh, on: :member   # sync status/duration from VdoCipher
      end
    end
  end
end
