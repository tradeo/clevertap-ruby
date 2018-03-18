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
__Available in v0.2.0 but will be depricated as of v1.0.0__
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

__As of v0.3.0 the new way of setting up CleverTap is:__
```ruby
CleverTap.setup do |config|
  # Default ID could be reset later
  # case by case when uploading Profile/Event
  config.identity_field = 'ID'

  config.account_id = 'the-account-id'
  config.account_passcode = 'the-passcode'
end
```

Then creating a shared instance to use trough the app (v0.3.0 and above)
```ruby
clevertap = CleverTap::Client.new

# You can add callbacks for successfull and failed calls as so:
clevertap.on_successful_upload do |response|
  # log the response as response.to_s
  # response is of type CleverTap::Response
  # having methods `success` (true or false)
  # and `failures` (empty if success == true)
  # contains hash with errors returned from CleverTap endpoint
end

clevertap.on_failed_upload do |response|
  ...
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

```ruby
profile = CleverTap::Profile.new(
  data: { 'ID' => 1, 'Name' => 'John Doe' }, # MANDATORY, expects to receive a hash containing the identity field specified in `CleverTap.setup`, or below
  identity_field: 'field_name' | false,      # optional
  fbid: '34322423',                          # optional, facebook id, can replace original identity
  gpid: '34322423',                          # optional, google plus id, can replace original identity
  objectId: '0f5d5fff698245f1ac5f192c',      # optional, uniq CleverTap identifier
  timestamp_field: 'Created At',             # optional, has to be present in the `data` hash, else it throws
  custom_timestamp: 1468308340               # optional, custom time stamp if user needs to set a particular timestamp, not presented in the object, takes precedence
)

clever_tap.upload(profile)
clever_tap.upload(profiles) # works as well with [CleverTap::Profile]
```

### Upload an event

__Available in v0.2.0 but will be depricated as of v1.0.0__
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
__As of v0.3.0 the new way of uploading Event(s) is:__
```ruby
event = CleverTap::Event.new(
  data: { 'ID' => 1, 'Field' => 'Value' } # MANDATORY, expects to receive a hash containing the identity field specified in `CleverTap.setup`, or below
  name: 'Event Name',                     # MANDATORY
  identity_field: 'field_name' | false,   # optional, has to be present in the `data` hash, else it throws
  fbid: '34322423',                       # optional, facebook id, can replace original identity
  gpid: '34322423',                       # optional, google plus id, can replace original identity
  objectId: '0f5d5fff698245f1ac5f192c',   # optional, uniq CleverTap identifier, can replace identity
  timestamp_field: 'Open Time',           # optional, has to be present in the `data` hash, else it throws
  custom_timestamp: 1468308340,           # optional, custom time stamp if user needs to set a particular timestamp, not presented in the object
)

clevertap.upload(event)
clevertap.upload(events) # Works as well with [CleverTap::Event]
```

### Send requests as *Dry Run*

Passing parameter `dry_run: true` to upload methods you can test the data submitted for a validation errors.
The record won't be persisted.

__Available in v0.2.0 but will be depricated as of v1.0.0__
```ruby
  client = CleverTap.new(account_id: '<your account ID>', passcode: '<your passcode>')
  client.upload_profile(profile, dry_run: true)
```

__As of v0.3.0 the new way of using a Dry Run is :__
```ruby
clevertap.upload(event, dry_run: true)
```

### Handle the response

The CleverTap response object has the following interface:
  1. `#status` - __"success"__ / __"partial"__ / __"fail"__
  2. `#success` - `true` when is the status is __"success"__ and `false` otherwise
  3. `#errors` - it's actually `unprocessed` synonym returned when the request is successful(code 200), but will contains the failed records even when the code is different than 200.
  4. `#code` - codes from 200-500. When it's __200__, errors can contains a validation
   error codes. When it's __-1__ the error is custom and more info can be found in the message. More info about the codes can find [CleverTap Docs](https://support.clevertap.com/docs/api/working-with-user-profiles.html#uploading-user-profiles)



####  __More documentation you can find in the specs__
