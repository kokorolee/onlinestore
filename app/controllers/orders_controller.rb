
class OrdersController < ApplicationController
  before_action :get_order#, only: [:show, :edit, :update, :payment]

  def show
    @order_items = current_order.order_items
    @limit_order_items = @order_items.page(params[:page]).per(1)
  end

  def payment
    # Build Payment object
    if current_user.full_name.nil?
      redirect_to edit_user_registration_path
    end

    if @order.user_id.nil?
      @order.update(user_id: current_user.id)
    end

    @payment = PayPal::SDK::REST::Payment.new({
      :intent =>  "sale",
      :payer =>  {
        :payment_method =>  "paypal" },
      :redirect_urls => {
        :return_url => ENV["HOST_NAME"] + payment_order_path(params[:id]),
        :cancel_url => ENV["HOST_NAME"] + products_path },
      :transactions =>  [{
        :amount =>  {
          :total =>  @order.subtotal,
          :currency =>  "USD" },
        :description =>  "This is the payment transaction description." }]})

      if @payment.create
        @payment.id     # Payment Id
      else
        @payment.error  # Error Hash
      end
      if !params[:token].nil? && !params[:PayerID].nil?
          @order.update(payment_id: params[:paymentId],
                      token_payment: params[:token],
                      payer_id: params[:PayerID])
      end
  end
  
  def execute
    @payment = PayPal::SDK::REST::Payment.find(@order.payment_id)
    if @payment.execute( :payer_id => @order.payer_id   )
      @order.update(order_status_id: 2) #Recevied
      current_order = Order.create(user_id: current_user.id)
      session[:order_id] = current_order.id
      flash[:notice] = 'Payment success!'
      redirect_to histories_path
    else
       flash[:alert] = @payment.error # Error Hash
       redirect_to order_path(@order)
    end
  end

  private
    def get_order
      @order = Order.find(params[:id])
    end
end
