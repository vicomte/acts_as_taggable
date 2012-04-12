module ActsAsTaggable
  module Taggable
    extend ActiveSupport::Concern

    module ClassMethods

      def taggable?
        false
      end

      ##
      # This is an alias for calling <tt>acts_as_taggable :tags</tt>.
      #
      # Example:
      #   class Book < ActiveRecord::Base
      #     acts_as_taggable
      #   end
      def acts_as_taggable
        acts_as_taggable_on :tags
      end

      ##
      # This is an alias for calling <tt>acts_as_ordered_taggable_on :tags</tt>.
      #
      # Example:
      #   class Book < ActiveRecord::Base
      #     acts_as_ordered_taggable
      #   end
      def acts_as_ordered_taggable
        acts_as_ordered_taggable_on :tags
      end

      ##
      # Make a model taggable on specified contexts.
      #
      # @param [Array] tag_types An array of taggable contexts
      #
      # Example:
      #   class User < ActiveRecord::Base
      #     acts_as_taggable :languages, :skills
      #   end
      def acts_as_taggable_on(*tag_types)
        taggable_on(false, tag_types)
      end


      ##
      # Make a model taggable on specified contexts
      # and preserves the order in which tags are created
      #
      # @param [Array] tag_types An array of taggable contexts
      #
      # Example:
      #   class User < ActiveRecord::Base
      #     acts_as_ordered_taggable_on :languages, :skills
      #   end
      def acts_as_ordered_taggable_on(*tag_types)
        taggable_on(true, tag_types)
      end

      private

      # Make a model taggable on specified contexts
      # and optionally preserves the order in which tags are created
      #
      # Seperate methods used above for backwards compatibility
      # so that the original acts_as_taggable method is unaffected
      # as it's not possible to add another arguement to the method
      # without the tag_types being enclosed in square brackets
      #
      # NB: method overridden in core module in order to create tag type
      #     associations and methods after this logic has executed
      #
      def taggable_on(preserve_tag_order, *tag_types)
        if taggable?
          self.tag_types = (self.tag_types + tag_types).flatten.uniq
          self.preserve_tag_order = preserve_tag_order
        else
          class_attribute :tag_types
          self.tag_types = tag_types
          class_attribute :preserve_tag_order
          self.tag_types = tag_types.flatten.compact.uniq.map(&:to_sym)
          self.preserve_tag_order = preserve_tag_order

          has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag, :class_name => "ActsAsTaggable::Extra::Tagging"
          has_many :base_tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggable::Tag"

          class_eval do
            include ActsAsTaggable::Extra::Utils
            include ActsAsTaggable::Core
            include ActsAsTaggable::Core::Collection
            include ActsAsTaggable::Core::Cache
            include ActsAsTaggable::Core::Ownership
            include ActsAsTaggable::Core::Related
            include ActsAsTaggable::Core::Dirty

          end
          def self.taggable?
            true
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActsAsTaggable::Taggable