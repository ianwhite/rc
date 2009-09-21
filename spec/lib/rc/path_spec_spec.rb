require File.dirname(__FILE__) + '/../../spec_helper'

describe "Rc::PathSpec" do
  it ".new(:foo, {:name => :bar, :singleton => true}, '*', '?owner') should create a path spec with 4 different specs" do
    path = Rc::PathSpec.new(:foo, {:name => :bar, :singleton => true}, '*', '?owner')
    path[0].should == Rc::Spec::Resources.new('foo')
    path[1].should == Rc::Spec::Resource.new('bar')
    path[2].should == Rc::Spec::Glob.new
    path[3].should == Rc::Spec::Polymorphic.new('owner')
  end
  
  describe "containing an incomplete spec" do
    before do
      @path = Rc::PathSpec.new :foo, '*', :bar
    end
    
    it "should be incomplete" do
      @path.should be_incomplete
    end
  end
  
  describe "containing no incomplete specs" do
    before do
      @path = Rc::PathSpec.new :foo, :bar
    end
    
    it "should not be incomplete" do
      @path.should_not be_incomplete
    end
  end
  
  it "#spec_with_key(:foo_id) should return first spec with that key" do
    path = Rc::PathSpec.new :foo, '*', :bar, :foo
    path.spec_with_key(:foo_id).should == path[0]
    path.spec_with_key(:not_there).should == nil
  end

  it "#spec_with_segment(:foos) should return first spec with that segment" do
    path = Rc::PathSpec.new :foo, '*', :bar, :foo
    path.spec_with_segment(:foos).should == path[0]
    path.spec_with_segment(:not_there).should == nil
  end
end