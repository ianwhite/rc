require File.dirname(__FILE__) + '/../spec_helper'

describe "Rc::Spec::Glob (expansion)" do
  before do
    @spec = Rc::Spec::Glob.new
  end
  
  it "should expand 'foo' to singleton spec" do
    @spec.expand(['foo']).should == [Rc::Spec.to_spec(:name => 'foo', :singleton => true)]
  end
  
  it "should expand 'foos', '1' to keyed spec" do
    @spec.expand(['foos', '1']).should == [Rc::Spec.to_spec(:name => 'foo')]
  end
  
  it "should expand 'foo', 'bar' to two singleton specs" do
    @spec.expand(['foo', 'bar']).should == [Rc::Spec.to_spec(:name => 'foo', :singleton => true), Rc::Spec.to_spec(:name => 'bar', :singleton => true)]
  end
  
  it "should expand 'foos', '1', 'bar' to keyed + singleton spec" do
    @spec.expand(['foos', '1', 'bar']).should == [Rc::Spec.to_spec(:name => 'foo'), Rc::Spec.to_spec(:name => 'bar', :singleton => true)]
  end
  
  describe "given a map {foos : '/foos/:bar_id'}" do
    before do
      @map = Rc::SpecMap.new({:name => 'foo', :key => 'bar_id'})
    end
    
    it "should expand 'foos', '1', 'bar' to mapped spec + singelton spec" do
      @spec.expand(['foos', '1', 'bar'], @map).should == [@map[:foo], Rc::Spec.to_spec(:name => 'bar', :singleton => true)]
    end
  end
  
  describe "given remaining specs :foo" do
    before do
      @remaining = [Rc::Spec.to_spec(:foo)]
    end
    
    it "should expand 'bar', 'foos', '2' to singleton spec (and ignore 'foos/2')" do
      @spec.expand(['bar', 'foos', '2'], nil, @remaining).should == [Rc::Spec.to_spec(:name => 'bar', :singleton => true)]
    end
  end
  
  describe "given remaining specs '?', :foo" do
    before do
      @remaining = [Rc::Spec.to_spec('?'), Rc::Spec.to_spec(:foo)]
    end
    
    it "should expand 'bar', 'baz', '1', 'foos', '2' to singleton spec (and ignore 'baz/1/foos/2')" do
      @spec.expand(['bar', 'baz', '1', 'foos', '2'], nil, @remaining).should == [Rc::Spec.to_spec(:name => 'bar', :singleton => true)]
    end
  end
  
  describe "given remaining specs '?', '?', :foo" do
    before do
      @remaining = [Rc::Spec.to_spec('?'), Rc::Spec.to_spec('?'), Rc::Spec.to_spec(:foo)]
    end
    
    it "should expand 'bar', 'faz', '3', 'baz', '1', 'foos', '2' to singleton spec (and ignore 'faz/3/baz/1/foos/2')" do
      @spec.expand(['bar', 'faz', '3', 'baz', '1', 'foos', '2'], nil, @remaining).should == [Rc::Spec.to_spec(:name => 'bar', :singleton => true)]
    end
  end
  
  describe "given remaining specs '?', '?'" do
    before do
      @remaining = [Rc::Spec.to_spec('?'), Rc::Spec.to_spec('?')]
    end
    
    it "should expand 'bar', 'faz', '3', 'baz', '1', 'foos', '2' to singleton spec, and :faz (and ignore 'baz/1/foos/2')" do
      @spec.expand(['bar', 'faz', '3', 'baz', '1', 'foos', '2'], nil, @remaining).should == [Rc::Spec.to_spec(:name => 'bar', :singleton => true), Rc::Spec.to_spec(:faz)]
    end
  end
end