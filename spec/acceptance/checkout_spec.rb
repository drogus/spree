require File.dirname(__FILE__) + '/acceptance_helper'

feature "Checkout", %q{
  In order to buy products
  As a user
  I want to be able to make checkout
} do

  scenario "Visitor make checkout as guest, without registration" do
    product = Fabricate(:product, :name => "RoR Mug", :price => "9.99")
    shipping_method = Fabricate(:shipping_method, :name => "UPS Ground")
    payment_method = Fabricate(:payment_method_check, :name => "Check")

    visit product_path(product)
    click_button "Add To Cart"
    page.should have_content("Shopping Cart")

    click_link "Checkout"
    page.should have_content("Registration")

    within "#guest_checkout" do
      fill_in "Email", :with => "spree@test.com"
      click_button "Continue"
    end

    page.should have_content("Billing Address")
    page.should have_content("Shipping Address")

    fill_in_address
    click_button "Save and Continue"

    within("legend") { page.should have_content("Shipping Method") }

    choose "order_shipping_method_id_#{shipping_method.id}"
    click_button "Save and Continue"

    choose "order_payments_attributes__payment_method_id_#{payment_method.id}"
    click_button "Save and Continue"

    page.should have_content("Order Summary")

    within("#line-items")  { page.should have_content("RoR Mug") }
    within("#order-total") { page.should have_content("9.99") }

    click_button "Place Order"

    page.should have_content("Your order has been processed successfully")
    Order.count.should == 1
  end

  scenario "Uncompleted order associated with user" do
    user = Fabricate(:user, :email => "john.doe@example.org", :password => "secret")
    sign_in(user)

    product = Fabricate(:product, :price => "14.99")
    visit product_path(product)
    click_button "Add To Cart"

    Order.count.should == 1
    order = Order.first
    order.item_total.should == 14.99
    order.user_id.should == user.id

    click_link "Logout"

    page.should have_content("Cart: (Empty)")

    visit product_path(product)
    click_button "Add To Cart"
    Order.count.should == 2
    User.count.should == 2
  end

  scenario "Uncompleted guest order should be associated with user after log in" do
    shipping_method = Fabricate(:shipping_method, :name => "UPS Ground")
    payment_method = Fabricate(:payment_method_check, :name => "Check")

    user = Fabricate(:user, :email => "john.doe@example.org", :password => "secret")

    product = Fabricate(:product, :price => "14.99")
    visit product_path(product)
    click_button "Add To Cart"

    Order.count.should == 1
    Order.first.user_id.should_not == user.id

    sign_in(user)

    page.should have_content("Shopping Cart")

    click_link "Checkout"
    page.should have_content("Billing Address")
    page.should have_content("Shipping Address")

    fill_in_address
    click_button "Save and Continue"

    # TODO: fix that after fixing capybara
    choose "order_shipping_method_id_#{shipping_method.id}"
    click_button "Save and Continue"

    choose "order_payments_attributes__payment_method_id_#{payment_method.id}"
    click_button "Save and Continue"

    click_button "Place Order"
    page.should have_content("Your order has been processed successfully")

    Order.count.should == 1
    Order.first.user_id.should == user.id
  end

  def sign_in(user)
    visit login_path

    fill_in "Email",    :with => user.email
    fill_in "Password", :with => "secret"

    click_button "Log In"
  end

  def fill_in_address(address = nil)
    address ||= Fabricate(:address)

    select "United States", :from => "Country"
    ['firstname', 'lastname', 'address1', 'city', 'state_name', 'zipcode', 'phone'].each do |field|
      fill_in "order_bill_address_attributes_#{field}", :with => address.send(field)
    end
    check "order_use_billing"
  end
end
