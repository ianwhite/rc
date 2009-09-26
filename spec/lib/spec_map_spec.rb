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
    
    it "should allow access by ['foos']" do
      @map["foos"].should == Rc::Spec.new(:foo)
    end
    
    it "should allow access by [:foos]" do
      @map[:foos].should == Rc::Spec.new(:foo)
    end
    
    it "when 2nd argument given to [], matches this against singleton" do
      @map[:foos, true].should_not be_truthy
      @map[:foos, false].should == Rc::Spec.new(:foo)
    end
    
    describe "#named" do
      it "returns spec matching name" do
        @map.named(:foo).should == Rc::Spec.new(:foo)
      end
    end
  
    describe "then << {:name => 'foo', :segment => 'bars'}" do
      before do
        @spec = Rc::Spec.to_spec(:name => 'foo', :segment => 'bars')
        @map << @spec
      end
      
      it "should add the new spec" do
        @map[:bars].should == @spec
      end
      
      describe "#with_params({:foo_id => 2, :bar_id => 3})" do
        before do
          @foo_spec = @map[:foos]
          @bar_spec = @map[:bars]
          @map = @map.with_params(:foo_id => 2, :bar_id => 3)
        end
        
        it "should not replace the :foos spec" do
          @map[:foos].should == @foo_spec
        end
        
        it "should not replace the :bars spec" do
          @map[:bars].should == @bar_spec
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