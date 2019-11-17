# frozen_string_literal: true

require 'scrypt'

module RSpec
  module Support
    module EncryptionHelpers
      # Generate password hashes compatible with Authlogic production code.
      def scrypt(input)
        SCrypt::Password.create(
          input,
          key_len: 32,
          salt_size: 8,
          max_mem: 1024**2,
          max_memfrac: 0.5,
          max_time: 0.2
        )
      end
    end
  end
end
