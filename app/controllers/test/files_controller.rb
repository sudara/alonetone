# frozen_string_literal: true

module Test
  # Serves mock files for upload fixtures.
  class FilesController < ActionController::Metal
    def show
      if exists?
        self.status = 200
        self.response_body = image_pathname.read
      else
        self.status = 404
      end
    end

    private

    def exists?
      case path.first
      when 'pics'
        Pic.where(pic_file_name: path.last).exists?
      else
        Rails.logger.info("[test-files] #{path.inspect} does not exist")
        false
      end
    end

    def path
      @path ||= request.path.split('/')[2..].map { |part| Rack::Utils.unescape(part) }
    end

    def image_pathname
      Rails.root.join('spec/fixtures/files/smallest.jpg')
    end
  end
end
