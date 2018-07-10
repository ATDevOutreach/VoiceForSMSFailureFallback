# Voice API: Using Voice API to Communicate with Customers and Remedy Frequently Failing Messages
#### INTRO 
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

#### VOICE WORKFLOW
To ensure communication with clients in cases where delivery reports indicate a different status from 'Success' the following workflow can be assumed:<br>
a. SMS is sent to the customer via AT API
- Delivery Report is a Success: Contact list updated with the status or as active
- Delivery Report is apart from Success: Contact list updated with status or inactive

b. On the next communication cycle, SMSes are sent to users with status Success or active, voice calls launched to all others:
- Delivery Report is a Success: No need to update contacts
- Delivery Report is a Otherwise: New status updated to Contacts
- Voice calls A Success: Contact List Updated as contacted Successfully
- Voice calls Fail: Contact List Updated

#### THE APP
We create a Ruby App running the simple Sinatra Framework, within a docker environment. The docker app runs a Postgres container alongside.[WIP]<br>
The files of note are:
- <b>Dockerfile:</b> to build the app and maintain one Ruby Version{Critical}
- <b>Gemfile:</b> for all the app dependencies
- <b>.env:</b> for all the Africa's Talking credentials and any other credentials/resources
- <b>app.rb:</b> the app in Ruby 'minimalist' Sinatra framework {Let the perfomance begin ;-)}
- <b>database.rb:</b> the database connector
- <b>docker-compose.yml:</b> for container orchestration

#### RUN THE APP
- Clone the Repo: 
````
$ git clone https://github.com/ATDevOutreach/VoiceForSMSFailureFallback.git VoiceSMS && cd VoiceSMS
````
- Build and Run the docker image:
````
$ sudo docker-compose build && docker-compose up
````
- To edit and rebuild:
````
$ sudo docker-compose down && docker-compose build
````

#### APP ENDPOINTS
##### /ussd
- Receives the USSD HTTP POST Request from Africastalking with the fields:
````
    @sessionId = params[:sessionId]
    @serviceCode = params[:serviceCode]
    @phoneNumber = params[:phoneNumber]
    @text = params[:text]
````
##### /dlr
- Receives the Delivery Reports HTTP POST Request from Africastalking with the fields:
````
    @id = params[:id]
    @status = params[:status]
    @phoneNumber = params[:phoneNumber]
    @networkCode = params[:networkCode]
    @failureReason = param[:failureReason]
````
##### /receiveSMS
- Receives the Incoming SMS HTTP POST Request from Africastalking for 2-Way SMS with the fields:
````
    @from = params[:from]
    @to = params[:to]
    @text = params[:text]
    @date = params[:date]
    @id = params[:id]
    #Where Available
    @linkId = params[:linkId]
````
##### /communicate
- Receives incoming API Call to Send SMS/Make Call and Voice HTTP POST Request from Africastalking:
````
    #SMS
    @to = params[:to]
    @message = params[:message]

    #VOICE
    @isActive = params[:isActive]
    @sessionId = params[:sessionId]
    @direction = params[:direction]
    @callerNumber = params[:callerNumber]
    @destinationNumber = params[:destinationNumber]
    @dtmfDigits = params[:dtmfDigits]
    @recordingUrl = params[:recordingUrl]
    @durationInSeconds = params[:durationInSeconds]
    @currencyCode = params[:currencyCode]
    @amount = params[:amount]
````

#### CURL THE ENDPOINTS
##### /ussd
````
curl -v -X POST -H "Content-Type: application/json" -d '{                                                                    
  "sessionId":"ATx138920183226162773",
  "serviceCode":"*384*303",
  "phoneNumber": "+254722000000",
  "text":"1"
}' "http://e978a1aa.ngrok.io/ussd"
````
##### /dlr
````
curl -v -X POST -H "Content-Type: application/json" -d '{                                                                    
  "id":"ATx138920183226162773",
  "status":"FAILED",
  "phoneNumber": "+254722000000",
  "networkCode": "63902",
  "failureReason":"UserIsInactive"
}' "http://e978a1aa.ngrok.io/dlr"
````
##### /receiveSMS
````
curl -v -X POST -H "Content-Type: application/json" -d '{                                                                    
  "from":"+254722000000",
  "to":"20414",
  "text":"Ruby",
  "date":"2018-07-10"
  "id":"ATidx138920183226162773",
  "linkId":"ATldx138920183226162773"
}' "http://e978a1aa.ngrok.io/receiveSMS"
````
##### /communicate
````
curl -v -X POST -H "Content-Type: application/json" -d '{                                                                    
  "to":"+254722000000",
  "message": "I am a lumberjack, I work all day and sleep all night!"
}' "http://e978a1aa.ngrok.io/communicate"
````
##### /communicate
````
curl -v -X POST -H "Content-Type: application/json" -d '{                                                                    
  "isActive":"1",
  "sessionId":"ATidx13892018322632001901",
  "direction":"outgoing",
  "callerNumber":"+254711082880",
  "destinationNumber":"+254722000000",
  "dtmfDigits":"",
  "recordingUrl":"http.cms.africastalking.com/xkdLsI"
  "durationInSeconds":"3.21",
  "currencyCode":"KES",
  "amount":"0.58"
}' "http://e978a1aa.ngrok.io/communicate"
````
