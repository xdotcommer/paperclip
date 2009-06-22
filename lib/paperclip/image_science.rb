module Paperclip
  # Handles thumbnailing images that are uploaded.
  class ImageScience < Thumbnail
    def initialize file, options = {}, attachment = nil
      geometry          = options[:geometry]
      @file             = file
      @crop             = geometry[-1,1] == '#'
      @target_geometry  = Geometry.parse geometry
      @current_geometry = Geometry.image_science_from_file @file
      @convert_options  = options[:convert_options]
      @whiny            = options[:whiny].nil? ? true : options[:whiny]
      @format           = options[:format]
      
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
    end

    # Performs the conversion of the +file+ into a thumbnail. Returns the Tempfile
    # that contains the new image.
    def make
      src = @file
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode
      
      begin
        ::ImageScience.with_image File.expand_path(src.path) do |img|
          img.resize @target_geometry.height, @target_geometry.width do |thumb|
            thumb.save File.expand_path(dst.path)
          end
        end
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error processing the thumbnail for #{@basename}" if @whiny
      end
      
      dst
    end
  end
end
