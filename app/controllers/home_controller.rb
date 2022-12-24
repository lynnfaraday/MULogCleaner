require 'log_parser'
require 'log_format_reader'

class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def parse
    file_data = params[:file]
    format = params[:log_format]
    begin
      parser = LogParser.new(format)
      begin
        lines = []        
        
        if file_data.respond_to?(:read)
          text = file_data.read
        elsif file_data.respond_to?(:path)
          text = File.read(file_data.path, { encoding: 'UTF-8'})
        else
          raise "Bad file_data: #{file_data.class.name}"
        end
                
        text.force_encoding('ASCII-8BIT').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?').split("\n").each do |l|
          lines << l
        end        
        @parsed_log = parser.parse(lines)
        @error = nil
      rescue Exception => e
        @parsed_log = ""
        @error = "Error reading file.  Please make sure it's a plain text log.  If it is, lease send this error to faraday@aresmush.com: \r\n\r\n#{e} #{e.backtrace}"
      end
    rescue Exception => e
      @parsed_log = ""
      @error = "Sorry!  Something went wrong.  Please send this error to faraday@aresmush.com: #{e}"
    end
  
    render :parse
  end
end
