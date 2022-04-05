FactoryBot.define do
  factory :vendor, class: Spree::Vendor do
    name { 'Test vendor' }
    about_us { 'About us...' }
    contact_us { 'Contact us...' }

    factory :active_vendor do
      name { 'Active vendor' }
      state { :active }
    end

    factory :blocked_vendor do
      name { 'Blocked vendor' }
      state { :blocked }
    end
  end
end
