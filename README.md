# clevertap-ruby
Module providing access to the [CleverTap](https://clevertap.com/) API

## Usage

### Configure the client

You should add your Account ID and Passcode for an authorization. You can get them from the settings in your CleverTap account.
```ruby
CLEVER_TAP = CleverTap.new(account_id: '<your account ID>', passcode: '<your passcode>')
```

You can add configuration settings as parameters like above or using a block.

```ruby
CLEVER_TAP = CleverTap.new(account_id: '<your account ID>', passcode: '<your passcode>') do |config|
  config.configure_faraday do |faraday_config|
    faraday_config.adapter :httpclient
  end

  config.profile_identity_field = 'ID'
  config.event_identity_field = 'User ID'
  config.event_identity_field_for 'deposit', 'Account ID'
end
```

### Upload a profile
Pass a object that responds to `.to_h` and `[]` to `.upload_profile`.
The result will be a CleverTap response object.

```ruby
profile = {
  'id' => '666',
  'Name' => 'Jonh Bravo'
}

client = CleverTap.new(account_id: '<your account ID>', passcode: '<your passcode>')
response = client.upload_profile(profile)

response.success # => true / false
response.status # => 'success' / 'partial' / 'fail'
response.errors # => [ {  }, ...]
```

The profile should always have an identity key as default its __id__ and
it's always passed to the CleverTap API as __identity__.
If your identity key is different then __id__ you can pass optional keyword parameter `identity_field: <name>`.

If pass optional keyword `date_field: <name>` as to the CleverTap API will be passed
timestamp when the profile is originally created.
The value should respond to `.to_i` and return epoch time. It's passed with key __ts__.
If it's missing the default is the current the time stamp.

### Upload an event

Pass a object that responds to `.to_h` and `[]` to `.upload_event` and an event name.
The name can be any string.
The result will be a CleverTap response object.

```ruby
event = {
  'User ID' => '666',
  'Name' => 'Jonh Bravo',
  'Cookie ID' => '424242'
}

client = CleverTap.new(account_id: '<your account ID>', passcode: '<your passcode>')
response = client.upload_event(event, name: 'registration', identity_field: 'User ID')

response.success # => true / false
response.status # => 'success' / 'partial' / 'fail'
response.errors # => [ {  }, ...]
```

Passing `identity_field` to the `upload_event` is mandatory!

If pass an optional keyword `date_field: <name>` as to the CleverTap API will be passed
timestamp when the event is originally created.
The value should respond to `.to_i` and return epoch time. It's passed with key *ts*.
If it's missing the default is the current the time stamp.

### Send requests as *Dry Run*
Passing parameter `dry_run: true` to upload methods you can test the data submitted for a validation errors.
The record won't be persisted.

```ruby
  client = CleverTap.new(account_id: '<your account ID>', passcode: '<your passcode>')
  client.upload_profile(profile, debug: true)
```

### Handle the response

The CleverTap response object the folloing interface:
  1. `.status` - __success__ / __partial__ / __fail__
  2. `.success` - __true__ when is the status is __success__ and __false__ otherwise
  3. `.errors` - it's actually a the value behind key `unprocessed` returned when the request is successful(code 200), but will contains the failed records even when the code is different than 200.
  4. `.code` - codes from 200-500. When it's __200__, errors can contains a validation
   errors codes. When it's __-1__ the error is custom and more info can be found in the message. More info about the codes can find [CleverTap Docs](https://support.clevertap.com/docs/api/working-with-user-profiles.html#uploading-user-profiles)



####  __More documentation you can find in the specs__
