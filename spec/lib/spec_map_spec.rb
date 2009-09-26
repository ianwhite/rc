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
    
    it "should allow access by ['foo']" do
      @map["foo"].should == Rc::Spec.new(:foo)
    end
    
    it "should default access by [:foo]" do
      @map[:foo].should == Rc::Spec.new(:foo)
    end
    
    describe "#for_segment" do
      it "returns spec matching segment when second argument not specified" do
        @map.for_segment(:foos).should == Rc::Spec.new(:foo)
      end
      
      it "when 2nd arg given, only returns spec if 2nd argument matches singleton?" do
        @map.for_segment(:foos, true).should_not be_truthy
        @map.for_segment(:foos, false).should == Rc::Spec.new(:foo)
      end
    end
  
    describe "then << {:name => 'foo', :segment => 'bars'}" do
      before do
        @spec = Rc::Spec.to_spec(:name => 'foo', :segment => 'bars')
        @map << @spec
      end
      
      it "should replace the old spec in all maps" do
        @map[:foo].should == @spec
        @map.for_segment(:foos).should_not be_truthy
        @map.for_segment(:bars).should == @spec
      end
      
      describe "#with_params({:foo_id => 2, :bar_id => 3})" do
        before do
          @map = @map.with_params(:foo_id => 2, :bar_id => 3)
        end
        
        it "should not replace the :foo spec" do
          @map[:foo].should == @spec
        end
        
        it "should have a :bar spec" do
          @map[:bar].should == Rc::Spec.to_spec(:bar)
        end
      end
    end
  end
  
  describe ".from_params" do
    it "(:foo => 1, :bar_id => 2) should return SpecMap.new(:bar)" do
      Rc::SpecMap.from_params(:foo => 1, :bar_id => 2) == Rc::SpecMap.new(:bar)
    end
  end
  
  describe "(set like)" do
    before do
      @map = Rc::SpecMap.new :foo, :bar
    end
    
    it "== is true when other is a SpecMap with == specs" do
      map = Rc::SpecMap.new :bar, :foo
      @map.should == map
    end
  
    it "#concat(array-like) conacts the array, calling Spec.to_spec on each element" do
      @map.concat([:faz, :fang])
      @map.should == Rc::SpecMap.new(:foo, :bar, :faz, :fang)
    end
    
    it "+ other returns new SpecMap" do
      addition = @map + [:faz]
      addition.should == Rc::SpecMap.new(:foo, :bar, :faz)
      @map.should == Rc::SpecMap.new(:foo, :bar)
    end
  end
end