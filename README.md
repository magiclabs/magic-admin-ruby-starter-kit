### 📣  The official Magic Admin Ruby SDK has been released. Please visit [magic-admin-ruby](https://github.com/magiclabs/magic-admin-ruby).

# [DEPRECATED] Magic Admin Starter Kit for Ruby

This Ruby Starter Kit implements the bare minimum functionality to support server-side Magic Admin authentication flow. It is created to demonstrate how each method can be implemented. It also serves as a lighweight SDK to allow developers to quickly prototype a server-side authentication flow with Magic in Ruby. This Ruby library should not be used directly in production because it has not been optimized yet. Please use this library for prototyping only.


It has implemented according to the Magic Admin SDK spec (doc will be shared separately):

- DID Token validation
- DID Token issuer retrival
- DID Token decode
- DID Token public address retrival
- User metadata retrival
- User logout


## Usage

**Step 1:**

Retrieve a `MAGIC_SECRET_API_KEY` from the dashboard: https://dashboard.magic.link.


**Step 2:**

Generate a DID Token client side (Follow https://docs.magic.link/client-sdk/browser-js). Once you have the DID Token, you can validate it (here we will use `irb`).

```
┌─[ajen@ajen-fortmatic] - [~/pg/magic-admin-ruby-starter-kit] $
└─[>] irb
irb(main):001:0> require "<PATH>/magic-admin-ruby-starter-kit/lib/magic-admin-ruby-starter-kit.rb"
=> true

irb(main):002:0> didt = "DIDT"
irb(main):003:0> Token.decode(didt)
```

**Step 3:**

Retrieve the issuer from a given DID Token.

```
┌─[ajen@ajen-fortmatic] - [~/pg/magic-admin-ruby-starter-kit] $
└─[>] irb
irb(main):001:0> require "<PATH>/magic-admin-ruby-starter-kit/lib/magic-admin-ruby-starter-kit.rb"
=> true

irb(main):002:0> didt = "DIDT"
irb(main):003:0> Token.get_issuer(didt)
=> "did:ethr:<public_address>"
```

**Step 4:**

Retrieve user metadata by an issuer.

```
┌─[ajen@ajen-fortmatic] - [~/pg/magic-admin-ruby-starter-kit] $
└─[>] irb
irb(main):001:0> require "<PATH>/magic-admin-ruby-starter-kit/lib/magic-admin-ruby-starter-kit.rb"
=> true

irb(main):003:0> User.get_metadata_by_issuer("did:ethr:<public_address>")
=> {"data"=>{"email"=>"email@example.com", "issuer"=>"did:ethr:<public_address>", "public_address"=>"<public_address>"}, "error_code"=>"", "message"=>"", "status"=>"ok"}
```

## Methods

### Token

- Token.decode
- Token.get_issuer
- Token.get_public_address
- Token.validate

### User

- Token.get_metadata_by_issuer
- Token.logout_by_issuer
