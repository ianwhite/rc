require File.dirname(__FILE__) + '/../spec_helper'

describe "Rc::Spec" do
  describe ".new('foo')" do
    before do
      @spec = Rc::Spec.new 'foo'
    end
  
    it "should not be singleton" do
      @spec.should_not be_singleton
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
    
    it "should have name_prefix: 'foo_'" do
      @spec.name_prefix.should == 'foo_'
    end
    
    it "should have class_name: 'Foo'" do
      @spec.class_name.should == 'Foo'
    end
    
    it "should have source: 'foos'" do
      @spec.source.should == 'foos'
    end
  end
  
  describe ".new('foo', :source => :bars)" do
    before do
      @spec = Rc::Spec.new 'foo', :source => :bars
    end
  
    it "should have key: 'bar_id'" do
      @spec.key.should == 'bar_id'
    end
    
    it "should have class_name: 'Bar'" do
      @spec.class_name.should == 'Bar'
    end
    
    it "should have source: 'bars'" do
      @spec.source.should == 'bars'
    end
  end
  
  describe ".new('foo', :name_prefix => false)" do
    before do
      @spec = Rc::Spec.new 'foo', :name_prefix => false
    end
  
    it "should have name_prefix: ''" do
      @spec.name_prefix.should == ''
    end
  end
  
  describe ".new('foo', :singleton => true)" do
    before do
      @spec = Rc::Spec.new 'foo', :singleton => true
    end
  
    it "should be singleton" do
      @spec.should be_singleton
    end
    
    it "should have name: 'foo'" do
      @spec.name.should == 'foo'
    end
    
    it "should have segment: 'foo'" do
      @spec.segment.should == 'foo'
    end
    
    it "should have name_prefix: 'foo_'" do
      @spec.name_prefix.should == 'foo_'
    end
    
    it "should have class_name: 'Foo'" do
      @spec.class_name.should == 'Foo'
    end
    
    it "should have source: 'foo'" do
      @spec.source.should == 'foo'
    end
  end
end