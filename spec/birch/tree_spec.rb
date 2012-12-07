require 'spec_helper'
require 'birch'

module Birch
  describe Tree do

    it "should initialize" do
      tree = Tree.new("value", "id")
      tree.value.should == "value"
      tree.id.should == "id"
      tree.parent.should be_nil
      tree.features.should {}
      tree.children.should == []
      tree.edges.should == []
      tree.size.should == 1
      tree.is_leaf?.should be_true
      tree.is_root?.should be_true
      tree.has_parent?.should be_false
      tree.has_children?.should be_false
      tree.has_edges?.should be_false
      tree.has_feature?(:feature).should be_false
      tree.has?(:feature).should be_false
      tree.has_features?.should be_false
    end

    it "should set id" do
      tree = Tree.new("value", "id")
      tree.id.should == "id"
      tree.id = "otherid"
      tree.id.should == "otherid"
    end

    it "should add" do
      tree = Tree.new("R", "root")
      a = Tree.new("A", "child A")
      b = Tree.new("B", "child B")
      c = Tree.new("C", "child C")
      
      tree << a
      tree.children.should == [a]

      tree << [b ,c]
      tree.has_children?.should be_true
      tree.children.should == [a, b, c]
      tree.has_edges?.should be_false
    end

    it "should set & get & unset" do
      tree = Tree.new("R", "root")
      tree.set(:afeature, "avalue")

      tree.get(:id).should == "root"
      tree.get("id").should be_nil
      tree.get(:value).should == "R"
      tree.get("value").should  be_nil
      tree.get(:afeature).should == "avalue"
      tree.get("afeature").should  be_nil

      tree.unset(:afeature)
      tree.get(:afeature).should be_nil
    end

    it "should compute total subtree size" do
      tree = Tree.new("R", "root")
      tree.size.should == 1

      a = Tree.new("A", "child A")
      tree << a
      tree.size.should == 2

      a << [Tree.new("B", "child B"), Tree.new("C", "child C")]
      a.children.size.should == 2
      a.size.should == 3
      tree.size.should == 4
    end

    it "should iterate over direct childen only using each" do
      tree = Tree.new("R", "root")
      tree.each{|t| raise("should not get here")}

      a = Tree.new("A", "child A")
      tree << a
      r = []
      tree.each{|t| r << t}
      r.should == tree.children

      a << [Tree.new("B", "child B"), Tree.new("C", "child C")]
      r = []
      tree.each{|t| r << t}
      r.should == tree.children

      r = []
      a.each{|t| r << t}
      r.should == a.children
    end

    it "should find first node with by id in subtree" do
      tree = Tree.new("R", "root")
      a = Tree.new("A", "child A")
      b = Tree.new("B", "child B")
      c = Tree.new("C", "child C")
      d = Tree.new("D", "child B")
      tree << [a, b]
      b << [c, d]
      tree.find("root").should be_nil
      tree.find("child A").should == a
      tree.find("child B").should == b
      tree.find("child C").should == c
      tree.find(a).should == a
      tree.find(b).should == b
      tree.find(c).should == c
      
      tree.find(d).should == b # since d id is "child B"
      b.find(d).should == d
    end

    it "should link" do
      a = Tree.new("A", "child A")
      b = Tree.new("B", "child B")
      edge1 = Edge.new(a, b, false)
      edge2 = Edge.new(a, b, true, a)

      a.link(edge1)
      a.edges.should == [edge1]
      edge1.directed.should be_false
      edge1.direction.should be_nil

      a.link(edge2)
      a.edges.should == [edge1, edge2]
      edge2.directed.should be_true
      edge2.direction.should == a
    end

    it "should set_as_root!" do
      a = Tree.new("A", "child A")
      b = Tree.new("B", "child B")
      a << b
      b.is_root?.should be_false
      b.set_as_root!.should == b
      b.is_root?.should be_true
      b.has_parent?.should be_false

      # TODO: should'nt it be removed from parent children?
      # a.has_children?.should be_false
    end

    it "should remove" do
      tree = Tree.new("R", "root")
      a = Tree.new("A", "child A")
      b = Tree.new("B", "child B")
      c = Tree.new("C", "child C")
      d = Tree.new("D", "child B")
      tree << [a, b]
      b << [c, d]

      lambda {tree.remove("child C")}.should raise_exception
      tree.remove("child B").should == b
      tree.children.should == [a]
      b.is_root?.should be_true
    end

    it "should remove_all!" do
      tree = Tree.new("R", "root")
      a = Tree.new("A", "child A")
      b = Tree.new("B", "child B")
      tree << [a, b]

      tree.remove_all!.should == tree
      tree.children.should == []

      a.has_parent?.should be_false
      a.is_root?.should be_true
      b.has_parent?.should be_false
      b.is_root?.should be_true
    end

  end
end


