module ActsAsTaggable
  module Tagger
    extend ActiveSupport::Concern

    module ClassMethods

      def is_tagger?
        false
      end

      ##
      # Make a model a tagger. This allows an instance of a model to claim ownership
      # of tags.
      #
      # Example:
      #   class User < ActiveRecord::Base
      #     acts_as_tagger
      #   end
      def acts_as_tagger(opts={})
        has_many :owned_taggings, opts.merge(:as => :tagger, :dependent => :destroy,
                                             :include => :tag, :class_name => "ActsAsTaggable::Extra::Tagging")
        has_many :owned_tags, :through => :owned_taggings, :source => :tag, :uniq => true, :class_name => "ActsAsTaggable::Tag"

        class_eval do
          def self.is_tagger?
            true
          end
        end
      end
    end

    ##
    # Tag a taggable model with tags that are owned by the tagger.
    #
    # @param taggable The object that will be tagged
    # @param [Hash] options An hash with options. Available options are:
    #               * <tt>:with</tt> - The tags that you want to
    #               * <tt>:on</tt>   - The context on which you want to tag
    #
    # Example:
    #   @user.tag(@photo, :with => "paris, normandy", :on => :locations)
    def tag(taggable, opts={})
      opts.reverse_merge!(:force => true)
      skip_save = opts.delete(:skip_save)
      return false unless taggable.respond_to?(:is_taggable?) && taggable.is_taggable?

      raise "You need to specify a tag context using :on"                unless opts.has_key?(:on)
      raise "You need to specify some tags using :with"                  unless opts.has_key?(:with)
      raise "No context :#{opts[:on]} defined in #{taggable.class.to_s}" unless (opts[:force] || taggable.tag_types.include?(opts[:on]))

      taggable.set_owner_tag_list_on(self, opts[:on].to_s, opts[:with])
      taggable.save unless skip_save
    end

    def is_tagger?
      self.class.is_tagger?
    end
  end
end

ActiveRecord::Base.send :include, ActsAsTaggable::Tagger
