module ActsAsTaggable
  module Core
    module Cache
      extend ActiveSupport::Concern

      included do
        # Skip adding caching capabilities if table not exists or no cache columns exist

        if table_exists? && tag_types.any? { |context| column_names.include?("cached_#{context.to_s.singularize}_list") }
          class_eval do
            before_save :save_cached_tag_list

            def save_cached_tag_list
              tag_types.map(&:to_s).each do |tag_type|
                if self.class.send("caching_#{tag_type.singularize}_list?")
                  if tag_list_cache_set_on(tag_type)
                    list = tag_list_cache_on(tag_type).to_a.flatten.compact.join(', ')
                    self["cached_#{tag_type.singularize}_list"] = list
                  end
                end
              end
              true
            end

          end
          initialize_acts_as_taggable_on_cache
        end
      end

      module ClassMethods
        def initialize_acts_as_taggable_on_cache
          tag_types.map(&:to_s).each do |tag_type|
            class_eval %(
            def self.caching_#{tag_type.singularize}_list?
              caching_tag_list_on?("#{tag_type}")
            end
          )
          end
        end

        def acts_as_taggable_on(*args)
          super(*args)
          initialize_acts_as_taggable_on_cache
        end

        def caching_tag_list_on?(context)
          column_names.include?("cached_#{context.to_s.singularize}_list")
        end
      end
    end
  end
end
