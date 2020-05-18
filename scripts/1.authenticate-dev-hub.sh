USER_ALIAS=DevHub
LOGIN_URL=http://login.salesforce.com
echo authenticating org w/ USER_ALIAS = $USER_ALIAS and LOGIN_URL = $LOGIN_URL
sfdx force:auth:web:login -d -a $USER_ALIAS -r $LOGIN_URL