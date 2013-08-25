#!/usr/bin/ruby

require 'rubygems'
require 'databasedotcom'


# Signal handler
Signal.trap(:INT) {
  puts "\nBye!"
  exit(0)
}
Signal.trap(:TERM) {
  puts "\nBye!"
  exit(0)
}


# Parse
if ARGV.size != 2
	puts("Missing username and/or password")
	puts("Usage: ruby agrep_cli <username> <password>")
	exit 1
else
	username = ARGV[0]
	password = ARGV[1]
end


# Create client
client = Databasedotcom::Client.new("config/agrep.yml")


# Login
print("Login ... ")
begin
	client.authenticate(:username =>username, :password =>password)
	print("succeeded", "\n\n")
rescue Databasedotcom::SalesForceError => err
	client = nil
	p err.message
end


# Select component
component_prompt = 'Select component([1]Apex|[2]Trigger|[3]VF|[4]Component): '
print(component_prompt)
while selected_component = STDIN.gets.chomp()
	case selected_component
	when "1"
		query = 'SELECT ID, Name, Body FROM ApexClass'
		break
	when "2"
		query = 'SELECT ID, Name, Body FROM ApexTrigger'
		break
	when "3"
		query = 'SELECT ID, Name, Markup FROM ApexPage'
		break
	when "4"
		query = 'SELECT ID, Name, Markup FROM ApexComponent'
		break
	else
		print(component_prompt)
	end
end


# Query for selected component
print("Query ... ")
begin
	result = client.query(query)
	print("succeeded", "\n\n")
rescue Databasedotcom::SalesforceError => err
	client = nil
	result = nil
	p err.message
end


# Search
search_prompt = "Input search key: "
print(search_prompt)
while line = STDIN.gets.chomp()
	count = 0
	reg = Regexp.compile(line)

	result.each do |record|
		if selected_component == "1" || selected_component == "2"
			if reg =~ record.Body
				print(client.instance_url, "/", record.Id, "\t")
				print(record.Name, "\n")
				count += 1
			end
		else
			if reg =~ record.Markup
				print(client.instance_url, "/", record.Id, "\t")
				print(record.Name, "\n")
				count += 1
			end
		end
	end
	print("=> ", count, " hits", "\n\n")
	print(search_prompt)
end
