require File.expand_path('../../spec_helper', __FILE__)

describe ActsAsTaggable::Extra::Tagging do
  before(:each) do
    clean_database!
    @tagging = ActsAsTaggable::Extra::Tagging.new
  end

  it "should not be valid with a invalid tag" do
    @tagging.taggable = TaggableModel.create(:name => "Bob Jones")
    @tagging.tag = ActsAsTaggable::Tag.new(:name => "")
    @tagging.context = "tags"

    @tagging.should_not be_valid
    
    @tagging.errors[:tag_id].should == ["can't be blank"]
  end

  it "should not create duplicate taggings" do
    @taggable = TaggableModel.create(:name => "Bob Jones")
    @tag = ActsAsTaggable::Tag.create(:name => "awesome")

    lambda {
      2.times { ActsAsTaggable::Extra::Tagging.create(:taggable => @taggable, :tag => @tag, :context => 'tags') }
    }.should change(ActsAsTaggable::Extra::Tagging, :count).by(1)
  end
  
end
