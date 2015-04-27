#!/usr/bin/env ruby

# Ensure the following environment variables are set properly:
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - AWS_REGION

require 'aws-sdk'
require 'yaml'

exit false unless ARGV && ARGV.length >= 1

hostname = ARGV[0]
ec2 = Aws::EC2::Client.new
result = ec2.describe_instances filters: [
  {
    name: 'private-dns-name',
    values: [hostname]
  }
]

# Make sure instance asking is AWS instance
return if !result.reservations.any? || !result.reservations.first.instances.any?

instance = result.reservations.first.instances.first
class_tag = instance.tags.find { |tag| tag.key == 'Puppet Class' }
classes = class_tag.value.split(',')
node_definition = { classes: classes }

# Output node definition
puts node_definition.to_yaml
