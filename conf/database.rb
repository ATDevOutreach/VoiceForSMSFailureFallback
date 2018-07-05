require 'sequel'
require 'pg'

#DATABASE
#Connect to DB default postgres, pwd: my password
DB = Sequel.connect('postgres://postgres:mysecretpassword@database/postgres')

#Contact Table
DB.create_table :contacts do
    primary_key :id
    String :phonenumber
    String :status
end
contacts = DB[:contacts] #Create dataset
#Populate the table
contacts.insert(:phonenumber => '+2348177779360', :status => 'Success')
contacts.insert(:phonenumber => '+254787235065', :status => 'Success')

#Balances Table
DB.create_table :balances do
    primary_key :id
    String :phonenumber
    Float :balance 
end
balances = DB[:balances] #Create dataset
#Populate the table
balances.insert(:phonenumber => '+2348177779360', :balance => rand * 100)
balances.insert(:phonenumber => '+254787235065', :balance => rand * 100)

#USSD Table
DB.create_table :ussdsessions do
    primary_key :id
    String :sessionid
    String :servicecode
    String :phonenumber
    String :text
end 
ussdsessions = DB[:ussdsessions] #Create dataset
#Populate the table
ussdsessions.insert(:sessionid => 'yahd761728339', :servicecode => '*384*147',:phonenumber => '+254787235065',:text => '1')

#DLRs Table
DB.create_table :dlrs do
    primary_key :id
    String :status
    String :dlrid
    String :phonenumber
    String :networkcode
    String :failurereason
end
dlrs = DB[:dlrs] #Create dataset
#Populate the table
dlrs.insert(:status => 'Success', :dlrid => 'AT1shfdtxakaka',:phonenumber => '+254787235065',:networkcode => '60555',:failurereason => 'Rejected')

#ReceivedSMS Table
DB.create_table :receivedsms do
    primary_key :id
    String :from
    String :to
    String :text
    String :datestring 
    String :messageid
    String :linkid
end
receivedsms = DB[:receivedsms] #Create dataset
#Populate the table
ussdsessions.insert(:from => '20880', :to => '+2348177779360',:text => 'Im a lumberjack',:datestring => '27-11-2018',:messageid => 'ATdctys399ajks',:linkid => 'AtDshaksh392001')

#Voice Table
DB.create_table :voicecalls do
    primary_key :id
    String :isactive
    String :sessionid
    String :direction
    String :callernumber
    String :destinationnumber
    String :dtmfdigits
    String :recordingurl
    String :durationinseconds
    String :currencycode
    String :amount
end
voicecalls = DB[:voicecalls] #Create dataset
#Populate the table
ussdsessions.insert(:isactive => '1', :sessionid => 'yahd761728339',:direction => 'incoming',:callernumber => '+254711082147',:destinationnumber => '+254787235065',:dtmfdigits => '1',:recordingurl => 'http://www.mp3.com/usxtlrs',:durationinseconds => '43sec',:currencycode => 'KES',:amount => '19.00')
