require File.dirname(__FILE__) + '/../spec_helper'

describe "Rc::Spec" do
  describe ".new('foo')" do
    before do
      @spec = Rc::Spec.new 'foo'
    end
  
    it "should not be singleton" do
      @spec.should_not be_singleton
    end
    
    it "should not be incomplete" do
      @spec.should_not be_incomplete
    end
    
    it "should have name: 'foo'" do
      @spec.name.should == 'foo'
    end
    
    it "should have segment: 'foos'" do
      @spec.segment.should == 'foos'
    end
    
    it "should have key: 'foo_id'" do
      @spec.key.should == 'foo_id'
    end
    
    it "should == Rc::Spec::Keyed.new('foo')" do
      @spec.should == Rc::Spec::Keyed.new('foo')
    end
  end
  
  describe ".new ''" do
    it "should raise ArgumentError" do
      lambda { @spec = Rc::Spec.new('') }.should raise_error(ArgumentError)
    end
  end
  
  describe ".new('foo', :as => 'bar')" do
    before do
      @spec = Rc::Spec.new 'foo', :as => 'bar'
    end
  
    it "should have as: 'bar'" do
      @spec.as.should == 'bar'
    end
  end
  
  describe ".new('foo', :singleton => true)" do
    before do
      @spec = Rc::Spec.new 'foo', :singleton => true
    end
  
    it "should be singleton" do
      @spec.should be_singleton
    end
    
    it "should not be incomplete" do
      @spec.should_not be_incomplete
    end
    
    it "should have name: 'foo'" do
      @spec.name.should == 'foo'
    end
    
    it "should have segment: 'foo'" do
      @spec.segment.should == 'foo'
    end
    
    it "should == Rc::Spec::Singleton.new('foo')" do
      @spec.should == Rc::Spec::Singleton.new('foo')
    end
  end
  
  describe ".new('!foo')" do
    before do
      @spec = Rc::Spec.new '!foo'
    end
    
    it "should == Rc::Spec::Singleton.new('foo')" do
      @spec.should == Rc::Spec::Singleton.new('foo')
    end
  end
  
  describe ".new('*')" do
    before do
      @spec = Rc::Spec.new '*'
    end
    
    it "should be a glob" do
      @spec.should be_glob
    end
    
    it "should be incomplete" do
      @spec.should be_incomplete
    end
    
    it "should == Rc::Spec::Glob" do
      @spec.should == Rc::Spec::Glob.new
    end
  end
  
  describe ".new('?')" do
    before do
      @spec = Rc::Spec.new '?'
    end
    
    it "should not be singleton" do
      @spec.should_not be_singleton
    end
    
    it "should not be glob" do
      @spec.should_not be_glob
    end
    
    it "should be incomplete" do
      @spec.should be_incomplete
    end
    
    it "should == Rc::Spec::Polymorphic.new" do
      @spec.should == Rc::Spec::Polymorphic.new
    end
  end
  
  describe ".new('?foo')" do
    before do
      @spec = Rc::Spec.new '?foo'
    end
    
    it "should be a Polymorphic" do
      @spec.should be_kind_of(Rc::Spec::Polymorphic)
    end
    
    it "should have as: 'foo'" do
      @spec.as.should == 'foo'
    end
    
    it "should == Rc::Spec::Polymorphic.new('foo')" do
      @spec.should == Rc::Spec::Polymorphic.new('foo')
    end
  end
  
  describe ".new('?foo', :singleton => true)" do
    before do
      @spec = Rc::Spec.new '?foo', :singleton => true
    end
    
    it "should be a Polymorphic" do
      @spec.should be_kind_of(Rc::Spec::Polymorphic)
    end
    
    it "should have as: 'foo'" do
      @spec.as.should == 'foo'
    end
    
    it "should be singleton" do
      @spec.should be_singleton
    end
  end
  
  describe ".to_spec" do
    it "(<a Spec>) should just return the spec" do
      spec = Rc::Spec.new :foo
      Rc::Spec.to_spec(spec).should == spec
    end
    
    it "(:foo) should call new(:foo)" do
      Rc::Spec.should_receive(:new).with(:foo)
      Rc::Spec.to_spec(:foo)
    end
    
    it "('foo') should call new('foo')" do
      Rc::Spec.should_receive(:new).with('foo')
      Rc::Spec.to_spec('foo')
    end
    
    it "(:name => 'foo', :singleton => true) should call new('foo', :singleton => true)" do
      Rc::Spec.should_receive(:new).with('foo', :singleton => true)
      Rc::Spec.to_spec(:name => 'foo', :singleton => true)
    end

    it "(1) should raise argument error" do
      lambda { Rc::Spec.to_spec(1) }.should raise_error(ArgumentError)
    end
  end
end