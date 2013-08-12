#!/usr/bin/ruby

require 'rubygems'
require 'databasedotcom'

# Parse
# (ToDo)

# Config
client = Databasedotcom::Client.new("config/agrep.yml")
username = ARGV[0]
password = ARGV[1]


# Login
print("Login ... ")
begin
	client.authenticate(:username =>username, :password =>password)
rescue Databasedotcom::SalesForceError => err
	client = nil
	p err.message
end
print("succeeded", "\n")


# Query for Apex
print("Query ... ")
begin
	result = client.query("SELECT ID, Name, Body FROM ApexClass")
rescue Databasedotcom::SalesforceError => err
	client = nil
	result = nil
	p err.message
end
print("done", "\n")


# Search
prompt = "Input search key: "
print(prompt)
while line = STDIN.gets.chomp()
	count = 0
	reg = Regexp.compile(line)

	result.each do |record|
		if reg =~ record.Body
			print(record.Id, "\t")
			print(record.Name, "\n")
			count += 1
		end
	end
	print(count, " hits", "\n\n")
	print(prompt)
end
