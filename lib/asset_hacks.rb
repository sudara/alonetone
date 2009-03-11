require 'aws/s3'

# Adds expiration headers to all stored S3 objects through duck-punching.
# Based on Keaka Jackson's original work.
# Sets cache_control and expires headers on all uploads
module AWS::S3
  class S3Object
    class << self
      MAX_AGE = 8.years
      def store_with_cache_control(key, data, bucket = nil, options = {})
        options[:cache_control] = "max-age=#{MAX_AGE.to_i}" unless options[:cache_control]
        options[:expires]       = MAX_AGE.from_now.httpdate unless options[:expires]
        store_without_cache_control(key, data, bucket, options)
      end
      alias_method_chain :store, :cache_control
    end
  end
end