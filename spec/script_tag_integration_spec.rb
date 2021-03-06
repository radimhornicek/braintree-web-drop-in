require_relative "helpers/skip_browser_helper"
require_relative "helpers/drop_in_helper"
require_relative "helpers/paypal_helper"

describe "Drop-in Script Tag Integration" do
  include SkipBrowser
  include DropIn
  include PayPal

  it "tokenizes a card" do
    visit_dropin_url("/script-tag-integration.html", false)

    click_option("card")
    hosted_field_send_input("number", "4111111111111111")
    hosted_field_send_input("expirationDate", "1019")
    hosted_field_send_input("cvv", "123")

    submit_pay

    expect(page).to have_current_path("/script-tag-result.html", :ignore_query => true)
    expect(page).to have_content("payment_method_nonce:")
  end

  it "tokenizes PayPal", :paypal do
    visit_dropin_url("/script-tag-integration.html", false)

    click_option("paypal")

    open_popup_and_complete_login

    expect(find("[data-braintree-id='methods-label']")).to have_content("Paying with")

    submit_pay

    expect(page).to have_current_path("/script-tag-result.html", :ignore_query => true)
    expect(page).to have_content("payment_method_nonce:")
  end

  it "does not submit form if card form is invalid" do
    visit_dropin_url("/script-tag-integration.html", false)

    click_option("card")
    hosted_field_send_input("number", "4111111111111111")

    submit_pay

    expect(page).to_not have_current_path("/script-tag-result.html", :ignore_query => true)
  end

  it "accepts data attributes as create options" do
    browser_skip("firefox", "Firefox can't run `have_content` on the options for some reason")

    visit_dropin_url("/script-tag-integration.html", false)

    # Accepts an array for payment option priority
    find("[data-braintree-id='choose-a-way-to-pay']")
    payment_options = all(:css, ".braintree-option__label")

    expect(payment_options[0]).to have_content("PayPal")
    expect(payment_options[1]).to have_content("Card")
    expect(payment_options[2]).to have_content("PayPal Credit")
  end
end
