module Panoramic
  class Resolver < ActionView::Resolver
    require "singleton"
    include Singleton

    def find_all(*args)
      logger = Logger.new(STDERR)
      # logger.debug "Panoramic find_all"
      clear_cache_if_necessary
      super
    end

    # this method is mandatory to implement a Resolver
    def find_templates(name, prefix, partial, details)
      logger = Logger.new(STDERR)
      # logger.debug "Panoramic find_templates"
      clear_cache_if_necessary
      conditions = {
        :path    => build_path(name, prefix),
        :locale  => normalize_array(details[:locale]).first,
        :format  => normalize_array(details[:formats]).first,
        :handler => normalize_array(details[:handlers]),
        :partial => partial || false
      }

      @@model.find_model_templates(conditions).map do |record|
        initialize_template(record)
      end
    end

    # Instantiate Resolver by passing a model (decoupled from ORMs)
    def self.using(model)
      @@model = model
      self.instance
    end

    private

    # Initialize an ActionView::Template object based on the record found.
    def initialize_template(record)
      source = record.body
      identifier = "#{record.class} - #{record.id} - #{record.path.inspect}"
      handler = ActionView::Template.registered_template_handler(record.handler)

      details = {
        :format => Mime[record.format],
        :updated_at => record.updated_at,
        :virtual_path => virtual_path(record.path, record.partial)
      }

      ActionView::Template.new(source, identifier, handler, details)
    end

    # Build path with eventual prefix
    def build_path(name, prefix)
      #if path name has file format in it, take it out
      # mime_types = Mime::SET.symbols.map{|mime| mime.to_s}
      # split_name = name.split(".")
      # if mime_types.include?(split_name.last)
        # name = split_name[0..split_name.size-2].join(".")
      # end
      prefix.present? ? "#{prefix}/#{name}" : name
    end

    # Normalize array by converting all symbols to strings.
    def normalize_array(array)
      array.map(&:to_s)
    end

    # returns a path depending if its a partial or template
    def virtual_path(path, partial)
      return path unless partial
      if index = path.rindex("/")
        path.insert(index + 1, "_")
      else
        "_#{path}"
      end
    end

    def clear_cache_if_necessary
      logger = Logger.new(STDERR)
      # logger.debug "Panoramic clear_cache_if_necessary"
      #last_updated = Rails.cache.fetch("panoramic_stored_template_last_updated") { Time.now }
      # logger.debug "Panoramic CACHE - Last Updated (from memcache): #{last_updated.inspect} - cache_last_updated value: #{@cache_last_updated.inspect}"
     # if @cache_last_updated.nil? || @cache_last_updated < last_updated
        # logger.debug "View Cache needs to be wiped"
     #   clear_cache
     #   @cache_last_updated = last_updated
     # end
    end

  end
end
