clevertap-ruby
==============

Module providing access to the [CleverTap](https://clevertap.com/) API

## Install
Add to your Gemfile

```ruby
gem 'clever_tap', github: 'tradeo/clevertap-ruby'
```

## Usage

### Configure the client

Create an instance of `CleverTap` object:
```ruby
CLEVER_TAP = CleverTap.new(account_id: '<your account ID>', passcode: '<your passcode>')
```

You can add configuration settings as parameters like above and/or using a block.
```ruby
CLEVER_TAP = CleverTap.new do |config|
  config.account_id = '<your account ID>' # mandatory
  config.passcode = '<your passcode>' # mandatory
  config.identity_field = 'ID' # default value "identity"

  config.configure_faraday do |faraday_config| # optional
    faraday_config.adapter :httpclient # default adapter "net_http"
  end
end
```

### Upload a profile

`.upload_profile` accepts as a first argument an object responding to `#to_h` and `#[]`.
```ruby
profile = {
  'identity' => '666',
  'Name' => 'John Bravo'
}

client = CleverTap.new(account_id: '<your account ID>', passcode: '<your passcode>')
response = client.upload_profile(profile)

response.success # => true / false
response.status # => 'success' / 'partial' / 'fail'
response.errors # => [ {  }, ...]
```

__Date field__ used as a time stamp is optional.
If it's missing the current time stamp will be send instead.
The value should respond to `.to_i` and return epoch time.

### Upload an event


`.upload_event` accepts as a first argument an object responding to `#to_h` and `#[]` and a second parameter keyword argument `name: <name>`.
```ruby
event = {
  'identity' => '666',
  'Name' => 'Jonh Bravo',
  'Cookie ID' => '424242'
}

client = CleverTap.new(account_id: '<your account ID>', passcode: '<your passcode>')
response = client.upload_event(event, name: 'registration')

response.success # => true / false
response.status # => 'success' / 'partial' / 'fail'
response.errors # => [ {  }, ...]
```

### Send requests as *Dry Run*

Passing parameter `dry_run: true` to upload methods you can test the data submitted for a validation errors.
The record won't be persisted.

```ruby
  client = CleverTap.new(account_id: '<your account ID>', passcode: '<your passcode>')
  client.upload_profile(profile, dry_run: true)
```

### Handle the response

The CleverTap response object has the following interface:
  1. `#status` - __"success"__ / __"partial"__ / __"fail"__
  2. `#success` - `true` when is the status is __"success"__ and `false` otherwise
  3. `#errors` - it's actually `unprocessed` synonym returned when the request is successful(code 200), but will contains the failed records even when the code is different than 200.
  4. `#code` - codes from 200-500. When it's __200__, errors can contains a validation
   error codes. When it's __-1__ the error is custom and more info can be found in the message. More info about the codes can find [CleverTap Docs](https://support.clevertap.com/docs/api/working-with-user-profiles.html#uploading-user-profiles)



####  __More documentation you can find in the specs__
