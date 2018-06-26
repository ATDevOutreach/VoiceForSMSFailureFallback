# Voice API: Using Voice API to Communicate with Frequently failing Messages
#### Introduction 
SMSes sent to customer phone numbers may fail due to several reasons:
1. Filled up SMS inbox {on the customers phone}
2. Customer phone is offline beyond the SMS retry period set by telco(varies upto 24 hours)
3. Issue with the users phone make

The SMS status may also be any of the following Statuses, apart from 'Success':
1. 'Sent'
2. 'Submitted'
3. 'Buffered'
4. 'Rejected'
5. 'Failed'

#### Voice Workflow
To ensure communication with clients in cases where delivery reports indicate a different status from 'Success' the following workflow can be assumed:<br>
a. SMS is sent to the customer via AT API
- Delivery Report is a Success: Contact list updated with the status or as active
- Delivery Report is apart from Success: Contact list updated with status or inactive

b. On the next communication cycle, SMSes are sent to users with status Success or active, voice calls launched to all others:
- Delivery Report is a Success: No need to update contacts
- Delivery Report is a Otherwise: New status updated to Contacts
- Voice calls A Success: Contact List Updated as contacted Successfully
- Voice calls Fail: Contact List Updated

#### The APP
We create a Ruby App running the simple Sinatra Framework, within a docker environment. The docker app runs a Postgres container alongside.[WIP]<br>
The files of note are:
- Dockerfile: to build the app and maintain one Ruby Version{Critical}
- Gemfile: for all the app dependencies
- .env: for all the Africa's Talking credentials and any other credentials/resources
- app.rb: the app in Ruby 'minimalist' Sinatra framework {Let the perfomance begin ;-)}
- database.rb: the database connector
- docker-compose.yml:for container orchestration
