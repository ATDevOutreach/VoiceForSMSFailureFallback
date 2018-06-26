#Choose Base File
FROM ruby:2.5

MAINTAINER graham@africastalking.com

#Update the base image
RUN apt-get update --fix-missing && apt-get upgrade -y && apt-get install -y wget 

#Install Postgresql
RUN apt-get install -y postgresql postgresql-contrib libpq-dev

#Check The Ruby Version
RUN ruby -v

#Make A Directory Where Our App Runs
RUN mkdir /smsvoice
WORKDIR /smsvoice

#Copy files to app
COPY . /smsvoice 

#Update and Install Gems{sinatra, dotenv}
RUN gem update --system 

RUN bundle install

#Run the App
CMD ["ruby", "app.rb"]