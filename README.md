# README

#### This is a prototype to implement Devise as a user authentication system, with omniauth to provide for authorization to other sytems, in particular document systems such as Google Docs, Office 365, etc.

## Successes:

#### Standard Devise Authentication with multiple omniauth providers (only google thus far).

#### Multiple emails for providers can be retained.

#### omniauth working and access token used for listing files.

#### rescue of authorization timed out by refreshing token using httparty post to google.

#### listing of files with next page token working.

## System dependencies:

#### Ruby version - ruby 2.4.1

#### Rails version - rails 5.1.2

#### Devise - for user authentication

#### Omniauth - for oauth2

#### omniauth-google-oauth2 - for google oauth2

#### google-api-client - for google drive files

## Database tables:

#### users: standard devise user table using email identification with required confirmation.

#### acceses: table of all authorizations from omniauth for all providers and emails for each user.

## Testing:

#### trying out minitest for model, controller and system tests.

#### bin/rails test test

#### ToDo: do tests using rspec for comparison.

#### ToDo: mocking and testing the google docs file listing.

## Security Implications (Note: this is only a prototype for proof of concept):

#### Note: the database contains the access and secrets for all users. This must be secured for a real site.

#### To Do: which fields to encrypt have not been determined yet, nor has the processes to secure the encryption keys.

#### If users try this system out, advise them to destroy any accesses when done.

## Setup for localhost:

### Set up project in Google APIs to get credentials to access google via oauth2:

### visit https://console.developers.google.com/apis/credentials/oauthclient/

### create a project with Google People API and Google Drive API libraries enabled.

### create credentials being sure to set the homepage url to http://localhost:3000 (for development) under OAuth consent

### create oauth2 client ID to give the webserver access to the google apis. You will need to place the Client ID and Client Secret values in the /config/secrets.yml file in the shared section.

## Run on localhost:

### bin/rails server

### http://localhost:3000

### sign up:

![sign up page](https://raw.githubusercontent.com/tayloredwebsites/OmniAccess/master/public/read_me_images/SignUpThruDevise.png)

### confirmation: get url from console and paste into browser to confirm.

### sign in:

![sign in page](https://github.com/tayloredwebsites/OmniAccess/blob/master/public/read_me_images/SignInThruDevise.png?raw=true)

### Home Page:

![home page](https://github.com/tayloredwebsites/OmniAccess/blob/master/public/read_me_images/HomePage.png?raw=true)

### list of authorized accesses:

![list of accesses](https://github.com/tayloredwebsites/OmniAccess/blob/master/public/read_me_images/ListOfRemoteAccesses.png?raw=true)

### list of files of an access (google drive):

![sign up page](https://github.com/tayloredwebsites/OmniAccess/blob/master/public/read_me_images/ListOfRemoteDocuments.png?raw=true)

### /users/sign_out to log out of application

## Notes:

#### Encryption of all tokens, codes, returned hash and other possible fields such as uid or state values should be done.

#### Should be run under https when in the internet.

#### Provision for multiple levels of access to a provider per user should be considered (requesting an update to the access level, or providing a separate access).

#### Going to the next page of files probably needs to have the next page token secured.

#### Currently have code to detect email not matching existing access record uid codes. This code probably needs to be thoroughly tested with actual providers.

#### Credential expiration time should be confirmed as valid and possibly used to update the access token (from the refresh token) before requesting files.

#### Needed to implement the refresh token process in the file listing request when the error 500 unauthorized system error after access token expires after only 1 hour.
