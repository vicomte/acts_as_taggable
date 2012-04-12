require "active_record"
require 'active_support/concern'

require "action_view"
require "digest/sha1"

$LOAD_PATH.unshift(File.dirname(__FILE__))

module ActsAsTaggable
  mattr_accessor :delimiter
  @@delimiter = ','

  mattr_accessor :force_lowercase
  @@force_lowercase = false

  mattr_accessor :force_parameterize
  @@force_parameterize = false

  mattr_accessor :remove_unused_tags
  self.remove_unused_tags = false

  def self.glue
    @@delimiter.ends_with?(" ") ? @@delimiter : "#{@@delimiter} "
  end

  def self.setup
    yield self
  end

  if defined?(ActiveRecord::Base)
    require "acts_as_taggable/extra/utils"
    require "acts_as_taggable/tag"
    require "acts_as_taggable/taggable"
    require "acts_as_taggable/tagger"
    require "acts_as_taggable/core/core"
    require "acts_as_taggable/core/cache"
    require "acts_as_taggable/core/collection"
    require "acts_as_taggable/core/dirty"
    require "acts_as_taggable/core/ownership"
    require "acts_as_taggable/core/related"
    require "acts_as_taggable/extra/tag_list"
    require "acts_as_taggable/extra/tagging"
    require "acts_as_taggable/extra/tags_helper"
    require "acts_as_taggable/extra/utils"
  end

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.extend ActsAsTaggable::Taggable
    ActiveRecord::Base.send :include, ActsAsTaggable::Tagger
  end

  if defined?(ActionView::Base)
    ActionView::Base.send :include, ActsAsTaggable::Extra::TagsHelper
  end

end



