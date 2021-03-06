require 'sinatra'
require "sinatra/reloader"
require_relative './conf/AfricasTalkingGateway'
require_relative './util/Database'
require 'dotenv'
Dotenv.load
require 'pg'

#Set port and bind
set :bind, '0.0.0.0'
set :logging, true
set :sessions, true

#Instantiate the gateway
gateway = AfricasTalkingGateway.new(ENV['AT_API_USERNAME'],ENV['AT_API_KEY_LIVE'])
#Create Database client
database = Database.new 
database.drop
#Create Tables
database.contacts
database.balances
database.ussdsessions
database.dlrs
database.receivedsms
database.voicecalls
#Seed Tables
database.seed

#Manage the USSD interactions
post '/ussd' do
    @sessionId = params[:sessionId]
    @serviceCode = params[:serviceCode]
    @phoneNumber = params[:phoneNumber]
    @text = params[:text]

    puts "Received USSD Session from AT -#{@sessionId} -#{@serviceCode} -#{@phoneNumber} -#{@text}"

    #Store USSD Session Details
    ussddone = database.storeUssd.insert(:sessionid => "#{@sessionId}",:servicecode=> "#{@serviceCode}",:phonenumber=> "#{@phoneNumber}",:text=> "#{@text}")
    puts "Database USSD Response #{@ussddone}"

    if(@text == "1")
        #Check the Database by phone for balance
        balance = "1500.00"

        #Return response
        response = "END Thank you for contacting Branch. Your balance is: \n"
        response += "Naira $balance"
    end
    body response
    status 200
end

#Manage Delivery Reports / Store to DB
post '/dlr' do
    @id = params[:id]
    @status = params[:status]
    @phoneNumber = params[:phoneNumber]
    @networkCode = params[:networkCode]
    @failureReason = params[:failureReason]
    #Print to console
    puts "Received dlr from AT -#{@id} -#{@status} -#{@phoneNumber} -#{@networkCode}  -#{@failureReason}"

    #Store dlr and update contacts table
    dlrsdone = database.storeDlr.insert(:dlrid => "#{@id}",:status=> "#{@status}",:phonenumber=> "#{@phoneNumber}",:networkcode=> "#{@networkCode}",:failurereason=> "#{@failureReason}")
    
    contactsdone = database.storeContact.where(:phonenumber => "#{@phoneNumber}").update(:status=> "#{@status}")

    puts "Inserted dlr #{dlrsdone} and updated contacts #{contactsdone}"
end

#Manage Incoming SMS
post '/receiveSMS' do
    @from = params[:from]
    @to = params[:to]
    @text = params[:text]
    @date = params[:date]
    @id = params[:id]
    #Where Available
    @linkId = params[:linkId]

    #Print to Console
    puts "Received sms from AT -#{@from} -#{@to} -#{@text} -#{@date} -#{@id} -#{@linkId}"

    #Store Incoming SMS
    rcvdsms = database.storeSMS.insert(:from => "#{@from}",:to =>"#{@to}",:text =>"#{@text}", :date =>"#{@date}", :id => "#{@id}", :linkid =>"#{@linkId}")
    puts "Inserts received SMS #{rcvdsms}"
end

#Send SMS or Voice call / First check if number failed before
post '/communicate' do
    #Params for Sending Communication
    @to = params[:to]
    @message = params[:message]

    #Params for Voice CallBack, When User picks Call
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

    #Values for making calls
    callFrom=ENV['AT_VOICE_NUMBER']
    callTo=params[:to]
    
    if (@sessionId != nil)
        #Populate the table
        voiceinsert = database.storeVoice.insert(:isactive => "#{@isActive}",:sessionid => "#{@sessionId}",:direction => "#{@direction}",:callernumber => "#{@callerNumber}",:destinationnumber => "#{@destinationNumber}",:dtmfdigits => "#{@dtmfDigits}",:recordingurl => "#{@recordingUrl}",:durationinseconds => "#{@durationInSeconds}",:currencycode => "#{@currencyCode}",:amount => "#{@amount}")
        puts "inserted voice call #{voiceinsert}"
    end
    
    #VOICE
    #If Voice call isActive == 1, Say
    if(@isActive == 1)
        response = "<?xml version='1.0' encoding='UTF-8'?><Response><Say>#{@message}</Say></Response>";
        body response
        status 201   
    end 

    #SMS
    #Check DB for Phone Number Status
    phonestatus = database.storeContact.where(phonenumber: "#{@to}", status: 'Success')
    if(phonestatus[:status] == 'Success' || phonestatus == nil)
        #Send Message as Usual
        reports = gateway.sendMessage(to, message)
        reports.each {|x|
            # status is either "Success" or "error message"
            puts 'number=' + x.number + ';status=' + x.status + ';statusCode=' + x.statusCode + ';messageId=' + x.messageId + ';cost=' + x.cost 

            #Store for Analytics
            storedcontact = database.storeContact.where(phonenumber: x.number).update(status: x.status)
            puts "updated contact #{storedcontact}"
        }
    else
        #Make Call and Play Message
        results = gateway.call(callFrom, callTo)

        results.each {|result|
            # Only status "Queued" means the call was successfully placed
            puts "Status= #{result.status} -#{phoneNumber}= #{result.phoneNumber}"
        }  
    end
end
