# frozen_string_literal: true

class StoreManagers::RegistrationsController < Devise::RegistrationsController
  include SmartYoyakuApi::User
  require 'json'

  before_action :sign_in_store_manager, only:[:show, :index]
  before_action :correct_store_manager, only:[:show, :index]
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # 登録内容の編集
  def show
    @store = current_store_manager.store
  end

  # 予約の確認
  def index
  end

  # 予約の詳細
  def details
  end

  # 新規登録画面
  def new
    @store_manager = StoreManager.new
    @store = @store_manager.build_store
    @image = @store.storeimages.build
    @plan = @store.plans.build
  end

  # POST /resource
  def create
    build_resource(sign_up_params)
    ActiveRecord::Base.transaction do
      resource.save
      yield resource if block_given?  
      # StoreManagerのsaveが成功した場合
      if resource.persisted?
        @masseur = create_masseur
        # 予約システム側でUser, Caledar, TaskCourseを作成
        set_store_and_plan
        @response = create_user(@store_manager, @store, @plan)    
        # @responseに含まれるtokenと各idを登録     
        update_resourses(@response)
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        redirect_to reserve_app_url
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end
  end


  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    ActiveRecord::Base.transaction do
      resource_updated = update_resource(resource, account_update_params)
      yield resource if block_given?
      if resource_updated
        set_flash_message_for_update(resource, prev_unconfirmed_email)
        bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

        respond_with resource, location: after_update_path_for(resource)
        # 予約システム側のUser情報を更新
        set_arguments
        @response = update_user(@name, @email, @password)
        unless JSON.parse(@response)["status"] == "200"
          raise StandardError, "予約システムでuserのupdateに失敗しました。"
        end   
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end  
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  #If you have extra params to permit, append them to the sanitizer.
  #def configure_sign_up_params
  #  devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  #end


  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  # アカウント登録後のリダイレクト先
  # def after_sign_up_path_for(resource)
  #   store_manager_path(current_store_manager)
  # end

  #アカウント編集後のリダイレクト先
  def after_update_path_for(resource)
    store_manager_path(current_store_manager)
  end

  # アクセスしたマッサージ師が現在ログインしているユーザーか確認します。
  def correct_store_manager
    unless StoreManager.find_by(id: params[:id]) == current_store_manager
      flash[:danger] = "アクセス権限がありません。"
      redirect_to store_manager_url(current_store_manager)
    end
  end

  # ログインしているかどうかの判定
  def sign_in_store_manager
    unless store_manager_signed_in?
      flash[:danger] = "ログインしてください。"
      redirect_to store_manager_session_url
    end
  end

  def create_masseur
    @store_manager.store.masseurs.create!(
      masseur_name: @store_manager.name,
      email: @store_manager.email,
      password: "password"
    )
  end

  def set_store_and_plan
    @store = @store_manager.store
    @plan = @store.plans.first
  end

  # 予約システム側で保持するtoken, idをポータルサイト側で保存
  def update_resourses(response)
    parsed_json = JSON.parse(response)
    @store_manager.update!(smart_token: parsed_json["user"]["token"])
    @store.update!(calendar_id: parsed_json["user"]["calendars"][0]["public_uid"], calendar_secret_id: parsed_json["user"]["calendars"][0]["id"])
    @plan.update!(course_id: parsed_json["user"]["calendars"][0]["task_courses"][0]["id"])
    @masseur.update!(staff_id: parsed_json["staff"]["id"])
  end

  def set_arguments
    @name = params[:store_manager][:name]
    @email = params[:store_manager][:email]
    @password = params[:store_manager][:password]
  end
end
