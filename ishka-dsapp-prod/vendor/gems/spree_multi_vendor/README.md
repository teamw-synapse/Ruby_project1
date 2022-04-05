# Spree Multi Vendor

[![Build Status](https://travis-ci.org/spree-contrib/spree_multi_vendor.svg?branch=master)](https://travis-ci.org/spree-contrib/spree_multi_vendor)

This is a [spree multi vendor marketplace](https://spreecommerce.org/use-cases/multi-vendor-marketplace/) extension. It's a great starting point if you're building a marketplace on top of [Spree](https://spreecommerce.org). Our goal was flexibility to allow you to tweak it to your needs. 

Check out this extension [multi vendor marketplace demo](https://spreecommerce.org/launch-a-multi-vendor-marketplace-within-a-few-weeks-with-spree-commerce/) and launch your marketplace within weeks, not months.

Developed and maintained by:

[![Spark Solutions](http://sparksolutions.co/wp-content/uploads/2015/01/logo-ss-tr-221x100.png)][spark]

## Features

You can create and manage Vendors who can manage on their own:

- [X] Orders
- [X] Products
- [X] Option Types
- [X] Properties
- [X] Stock Locations
- [X] Shipping Methods
- [X] Vendor profile

Also:
- [X] Super Admins can assign Users to Vendors
- [X] You can modify which permissions and models/resources Vendors can manage quite easily

Contributions welcome! :)

## Installation

1. Add this extension to your Gemfile with this line:
    ```ruby
    gem 'spree_multi_vendor', github: 'spree-contrib/spree_multi_vendor'
    ```

2. Install the gem using Bundler:
    ```ruby
    bundle install
    ```

3. Copy & run migrations
    ```ruby
    bundle exec rails g spree_multi_vendor:install
    ```

4. Restart your server

    If your server was running, restart it so that it can find the assets properly.

5. Optionally you can also create sample Vendor by running:

   ```bash
   bundle exec rake spree_multi_vendor:sample:create
   ```

## Upgrading

1. Fetch new database migrations:

    ```bash
    bundle exec rake railties:install:migrations FROM=spree_multi_vendor
    ```

2. Run migrations

    ```bash
    bundle exec rails db:migrate
    ```

## Testing

First bundle your dependencies, then run `rake`. `rake` will default to building the dummy app if it does not exist, then it will run specs. The dummy app can be regenerated by using `rake test_app`.

```shell
bundle
bundle exec rake
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_multi_vendor/factories'
```

## Contributing

If you'd like to contribute, please take a look at the
[instructions](CONTRIBUTING.md) for installing dependencies and crafting a good
pull request.

## License

Spree Multi Vendor is copyright © 2017-2018
[Spark Solutions Sp. z o.o.][spark]. It is free software,
and may be redistributed under the terms specified in the
[LICENCE](LICENSE) file.

[LICENSE]: https://github.com/spark-solutions/spree_braintree_vzero/blob/master/LICENSE

## About Spark Solutions

[![Spark Solutions](http://sparksolutions.co/wp-content/uploads/2015/01/logo-ss-tr-221x100.png)][spark]

Spree Vendors is maintained by [Spark Solutions Sp. z o.o.](http://sparksolutions.co?utm_source=github)

We are passionate about open source software.
We are [available for hire][spark].

[spark]:http://sparksolutions.co?utm_source=github