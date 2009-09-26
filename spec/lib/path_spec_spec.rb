require File.dirname(__FILE__) + '/../spec_helper'

describe "Rc::PathSpec" do
  it ".new(:foo, {:name => :bar, :singleton => true}, '*', '?owner') should create a path spec with 4 different specs" do
    path = Rc::PathSpec.new(:foo, {:name => :bar, :singleton => true}, '*', '?owner')
    path[0].should == Rc::Spec::Keyed.new('foo')
    path[1].should == Rc::Spec::Singleton.new('bar')
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

  describe "(array like)" do
    before do
      @path = Rc::PathSpec.new :foo, :bar
    end
    
    it "== is true when other is a PathSPec with == specs" do
      path = Rc::PathSpec.new :foo, :bar
      @path.should == path
    end
    
    it "[n] returns nth element of specs" do
      @path[1].should == Rc::Spec.new(:bar)
    end
    
    it "[n..m] returns PathSpec with specified range" do
      @path[1..-1].should == Rc::PathSpec.new(:bar)
    end
  
    it "#concat(array) conacts the array, calling Spec.to_spec on each element" do
      @path.concat([:faz, :fang])
      @path.should == Rc::PathSpec.new(:foo, :bar, :faz, :fang)
    end
    
    it "#conact(PathSpec) concats the PathSpec's specs directly" do
      other = Rc::PathSpec.new(:faz)
      @path.send(:specs).should_receive(:concat).with(other.send(:specs))
      @path.concat(other)
    end
    
    it "+ other returns new PathSpec" do
      addition = @path + [:foo]
      addition.should == Rc::PathSpec.new(:foo, :bar, :foo)
      @path.should == Rc::PathSpec.new(:foo, :bar)
    end
  end
  
  describe "(Ensure determinate pathspec) : PathSpec.new(:foo, '*')" do
    before do
      @path = Rc::PathSpec.new :foo, '*'
    end
    
    it "should allow << '?'" do
      lambda { @path << '?' }.should_not raise_error
    end

    it "should allow << '?' << :foo << '*' " do
      lambda { @path << '?' << :foo << '*' }.should_not raise_error
    end
    
    it "should not allow << '*'" do
      lambda { @path << '*' }.should raise_error(ArgumentError)
    end
    
    it "should not allow << '?' << '*'" do
      lambda { @path << '?' << '*' }.should raise_error(ArgumentError)
    end
  end
  
  describe "#match?(path)" do
    it "Incomplete PathSpec should not match" do
      Rc::PathSpec.new('*').should_not be_match('x')
    end
    
    it "PathSpec(:foo) should match '/foos/2'" do
      Rc::PathSpec.new(:foo).should be_match('/foos/2')
    end
    
    it "PathSpec(:foo) should not match '/foos'" do
      Rc::PathSpec.new(:foo).should_not be_match('/foos')
    end
    
    it "PathSpec(:foo) should not match '/foos/2/bar'" do
      Rc::PathSpec.new(:foo).should_not be_match('/foos/2/bar')
    end
    
    it "PathSpec(:foo, :bar) should match '/foos/2/bars/1'" do
      Rc::PathSpec.new(:foo, :bar).should be_match('/foos/2/bars/1')
    end
    
    it "PathSpec({:name => :foo, :singleton => true}, :bar) should match '/foo/bars/2'" do
      Rc::PathSpec.new({:name => :foo, :singleton => true}, :bar).should be_match('/foo/bars/2')
    end
    
    it "PathSpec({:name => :foo, :singleton => true}, :bar) should not match '/foo/bars/2/1'" do
      Rc::PathSpec.new({:name => :foo, :singleton => true}, :bar).should_not be_match('/foo/bars/2/1')
    end
  end
  
  describe "#expand(path)" do
    it "should return self if complete" do
      spec = Rc::PathSpec.new(:foo)
      spec.expand('').should == spec
    end
    
    describe "with PathSpec(:foo, '?')" do
      before do
        @pathspec = Rc::PathSpec.new(:foo, '?')
      end
      
      it "should expand '/foos/1/bars/2' to PathSpec.new(:foo, :bar)" do
        @pathspec.expand!('/foos/1/bars/2').should == Rc::PathSpec.new(:foo, :bar)
      end
      
      it "should not expand '/foos/1/bar'" do
        @pathspec.expand('/foos/1/bar').should == false
      end

      it "should not expand '/foos/1/bars/2/baz'" do
        @pathspec.expand('/foos/1/bars/2/baz').should == false
      end
      
      describe "where map exists with baz: bars/:bar_id" do
        before do
          @map = Rc::SpecMap.new(:name => :baz, :segment => :bars, :source => :bars)
        end
        
        it "should expand '/foos/1/bars/2', map to PathSpec.new(:foo, <the mapped spec>)" do
          @pathspec.expand!('/foos/1/bars/2', @map).should == Rc::PathSpec.new(:foo, @map[:baz])
        end
      end
    end
    
    describe "with PathSpec('*', :foo)" do
      before do
        @pathspec = Rc::PathSpec.new('*', :foo)
      end
      
      it "should expand '/foos/1' to PathSpec.new(:foo)" do
        @pathspec.expand!('/foos/1').should == Rc::PathSpec.new(:foo)
      end
      
      it "should expand '/bar/foos/1' to PathSpec.new({:name => :bar, :singleton => true}, :foo)" do
        @pathspec.expand!('/bar/foos/1').should == Rc::PathSpec.new({:name => :bar, :singleton => true}, :foo)
      end
      
      it "should expand '/bars/2/baz/foos/1' to PathSpec.new(:bar, {:name => :baz, :singleton => true}, :foo)" do
        @pathspec.expand!('/bars/2/baz/foos/1').should == Rc::PathSpec.new(:bar, {:name => :baz, :singleton => true}, :foo)
      end
    end
    
    describe "with PathSpec('*', '?owner')" do
      before do
        @pathspec = Rc::PathSpec.new('*', '?owner')
      end
      
      it "should expand '/bar/foos/1' to PathSpec.new({:name => :bar, :singleton => true}, {:name => :foo, :as => :owner})" do
        @pathspec.expand!('/bar/foos/1').should == Rc::PathSpec.new({:name => :bar, :singleton => true}, {:name => :foo, :as => :owner})
      end
      
      it "should expand '/foos/1' to PathSpec.new({:name => :foo, :as => :owner})" do
        @pathspec.expand!('/foos/1').should == Rc::PathSpec.new({:name => :foo, :as => :owner})
      end
    end
  end
end