require File.dirname(__FILE__) + '/../spec_helper'

describe "Rc::SpecMap" do
  describe "#store" do
    before do
      @map = Rc::SpecMap.new
    end
  
    it "should allow storage of complete Spec" do
      lambda { @map << Rc::Spec.new('foo') }.should_not raise_error
      lambda { @map << Rc::Spec.new('foo', :singleton => true) }.should_not raise_error
    end
  
    it "should raise ArgumentError on storage of incomplete Spec" do
      lambda { @map << Rc::Spec.new('*') }.should raise_error(ArgumentError)
      lambda { @map << Rc::Spec.new('?') }.should raise_error(ArgumentError)
    end
  end
  
  describe ".new(:foo)" do
    before do
      @map = Rc::SpecMap.new(:foo)
    end
    
    it "should store spec by name" do
      @map.by_name.should == { "foo" => Rc::Spec.new(:foo) }
    end
    
    it "should store spec by segment" do
      @map.by_segment.should == { "foos" => Rc::Spec.new(:foo) }
    end

    it "should store spec by key" do
      @map.by_key.should == { "foo_id" => Rc::Spec.new(:foo) }
    end
  
    it "should default access by name" do
      @map[:foo].should == Rc::Spec.new(:foo)
    end
  
    describe "then << {:name => 'foo', :segment => 'bars', :key => 'bar_id'}" do
      before do
        @map << {:name => 'foo', :segment => 'bars', :key => 'bar_id'}
      end
      
      it "should replace the old spec in all maps" do
        spec = Rc::Spec.to_spec(:name => 'foo', :segment => 'bars', :key => 'bar_id')
        @map.by_name.should == {"foo" => spec}
        @map.by_key.should == {"bar_id" => spec}
        @map.by_segment.should == {"bars" => spec}
      end
    end
  end  
end