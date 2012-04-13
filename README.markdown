# ActsAsTaggable

### General information

Adds functionality tags to models.

## Installation

To use it, add it to your Gemfile:

    gem 'acts_as_taggable', :git => 'git@github.com:ivoreis/acts_as_taggable.git'

### Post Installation

1. rails generate acts_as_taggable:migration
2. rake db:migrate


### Configuration

If you would like to remove unused tag objects after removing taggings, add

  ActsAsTaggable.remove_unused_tags = true

If you want force tags to be saved downcased:

  ActsAsTaggable.force_lowercase = true

If you want tags to be saved parametrized (you can redefine to_param as well):

  ActsAsTaggable.force_parameterize = true


### Testing

Acts As Taggable uses RSpec for its test coverage

    rake spec

## Usage

```ruby
    class User < ActiveRecord::Base
      # Alias for acts_as_taggable_on :tags
      acts_as_taggable
      acts_as_taggable_on :skills, :interests
    end

    @user = User.new(:name => "Bobby")
    @user.tag_list = "awesome, slick, hefty"      # this should be familiar
    @user.skill_list = "joking, clowning, boxing" # but you can do it for any context!
    @user.skill_list                              # => ["joking","clowning","boxing"] as TagList
    @user.save

    @user.tags # => [<Tag name:"awesome">,<Tag name:"slick">,<Tag name:"hefty">]
    @user.skills # => [<Tag name:"joking">,<Tag name:"clowning">,<Tag name:"boxing">]

    @frankie = User.create(:name => "Frankie", :skill_list => "joking, flying, eating")
    User.skill_counts # => [<Tag name="joking" count=2>,<Tag name="clowning" count=1>...]
    @frankie.skill_counts
```
=== Finding Tagged Objects

Acts As Taggable On utilizes named_scopes to create an association for tags.
This way you can mix and match to filter down your results, and it also improves
compatibility with the will_paginate gem:

```ruby
    class User < ActiveRecord::Base
      acts_as_taggable_on :tags, :skills
      scope :by_join_date, order("created_at DESC")
    end

    User.tagged_with("awesome").by_date
    User.tagged_with("awesome").by_date.paginate(:page => params[:page], :per_page => 20)

    # Find a user with matching all tags, not just one
    User.tagged_with(["awesome", "cool"], :match_all => true)

    # Find a user with any of the tags:
    User.tagged_with(["awesome", "cool"], :any => true)

    # Find a user that not tags with awesome or cool:
    User.tagged_with(["awesome", "cool"], :exclude => true)

    # Find a user with any of tags based on context:
    User.tagged_with(['awesome, cool'], :on => :tags, :any => true).tagged_with(['smart', 'shy'], :on => :skills, :any => true)
```

  You can also use :wild => true option along with :any or :exclude option. It will looking for %awesome% and %cool% in sql.

  Tip: User.tagged_with([]) or '' will return [], but not all records.

### Relationships

You can find objects of the same type based on similar tags on certain contexts.
Also, objects will be returned in descending order based on the total number of
matched tags.

```ruby
    @bobby = User.find_by_name("Bobby")
    @bobby.skill_list # => ["jogging", "diving"]

    @frankie = User.find_by_name("Frankie")
    @frankie.skill_list # => ["hacking"]

    @tom = User.find_by_name("Tom")
    @tom.skill_list # => ["hacking", "jogging", "diving"]

    @tom.find_related_skills # => [<User name="Bobby">,<User name="Frankie">]
    @bobby.find_related_skills # => [<User name="Tom">]
    @frankie.find_related_skills # => [<User name="Tom">]
```

### Dynamic Tag Contexts

In addition to the generated tag contexts in the definition, it is also possible
to allow for dynamic tag contexts (this could be user generated tag contexts!)

```ruby
    @user = User.new(:name => "Bobby")
    @user.set_tag_list_on(:customs, "same, as, tag, list")
    @user.tag_list_on(:customs) # => ["same","as","tag","list"]
    @user.save
    @user.tags_on(:customs) # => [<Tag name='same'>,...]
    @user.tag_counts_on(:customs)
    User.tagged_with("same", :on => :customs) # => [@user]
```

### Tag Ownership

Tags can have owners:

```ruby
    class User < ActiveRecord::Base
      acts_as_tagger
    end

    class Photo < ActiveRecord::Base
      acts_as_taggable_on :locations
    end

    @some_user.tag(@some_photo, :with => "paris, normandy", :on => :locations)
    @some_user.owned_taggings
    @some_user.owned_tags
    @some_photo.locations_from(@some_user) # => ["paris", "normandy"]
    @some_photo.owner_tags_on(@some_user, :locations) # => [#<ActsAsTaggable::Tag id: 1, name: "paris">...]
    @some_photo.owner_tags_on(nil, :locations) # => Ownerships equivalent to saying @some_photo.locations
    @some_user.tag(@some_photo, :with => "paris, normandy", :on => :locations, :skip_save => true) #won't save @some_photo object
```

### Dirty objects

```ruby
    @bobby = User.find_by_name("Bobby")
    @bobby.skill_list # => ["jogging", "diving"]

    @boddy.skill_list_changed? #=> false
    @boddy.changes #=> {}

    @bobby.skill_list = "swimming"
    @bobby.changes.should == {"skill_list"=>["jogging, diving", ["swimming"]]}
    @boddy.skill_list_changed? #=> true

    @bobby.skill_list_change.should == ["jogging, diving", ["swimming"]]
```ruby

### Tag cloud calculations

To construct tag clouds, the frequency of each tag needs to be calculated.
Because we specified +acts_as_taggable_on+ on the <tt>User</tt> class, we can
get a calculation of all the tag counts by using <tt>User.tag_counts_on(:customs)</tt>. But what if we wanted a tag count for
an single user's posts? To achieve this we call tag_counts on the association:

```ruby
  User.find(:first).posts.tag_counts_on(:tags)
```

A helper is included to assist with generating tag clouds.

Here is an example that generates a tag cloud.

Helper:

```ruby
  module PostsHelper
    include ActsAsTaggable::TagsHelper
  end
```

Controller:

```ruby
  class PostController < ApplicationController
    def tag_cloud
      @tags = Post.tag_counts_on(:tags)
    end
  end
```

View:

```ruby
  <% tag_cloud(@tags, %w(css1 css2 css3 css4)) do |tag, css_class| %>
    <%= link_to tag.name, { :action => :tag, :id => tag.name }, :class => css_class %>
  <% end %>
```ruby

CSS:
```ruby
  .css1 { font-size: 1.0em; }
  .css2 { font-size: 1.2em; }
  .css3 { font-size: 1.4em; }
  .css4 { font-size: 1.6em; }
```


## Credits
* Michael Bleigh, author of the original acts_as_taggable
* Artem Kramarenko (artemk)
* {From the original project}[https://github.com/mbleigh/acts-as-taggable-on/contributors]



## License
Copyright (c) 2012 Michael Bleigh (http://mbleigh.com/) and Intridea Inc. (http://intridea.com/), Ivo Reis, released under the MIT license
