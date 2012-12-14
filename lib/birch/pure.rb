module Birch

  class Tree
    
    attr_accessor :id, :value
    attr_accessor :parent, :features
    attr_reader :children, :edges

    def initialize(value, id)
      @value, @id = value, id
      @parent = nil
      @children = []
      @children_hash = {}
      @features = {}
      @edges = []
    end

    def root
      @parent.nil? ? self : root(parent)
    end

    def add(node_or_nodes)
      nodes = [*node_or_nodes]
      nodes.each do |node|
        @children << node
        @children_hash[node.id] = node
        node.parent = self
      end
      nodes.first
    end
    alias_method :<<, :add

    def get(feature)
      case feature
      when :id 
        @id
      when :value
        @value
      else
        @features[feature]
      end
    end
    alias_method :[], :get

    def set(feature, value)
      @features[feature] = value
    end 
    alias_method :[]=, :set

    def unset(feature)
      @features.delete(feature)
    end

    def size
      1 + (@children.map(&:size).reduce(:+) || 0)
    end

    def each
      @children.each{|c| yield c}
    end

    def find(id_or_node)
      id = id_or_node.is_a?(Tree) ? id_or_node.id : id_or_node
      return @children_hash[id] if @children_hash.has_key?(id)
      @children.each{|c|  r = c.find(id); return r if r}
      nil
    end

    def is_leaf?; @children.empty?; end
    def is_root?; @parent.nil?; end
    def has_children?; !@children.empty?; end
    def has_edges?; !@edges.empty?; end
    def has_parent?; !@parent.nil? ;end
    def has_features?; !@features.empty?; end

    def has_feature?(feature)
      @features.has_key?(feature)
    end

    alias_method :has?, :has_feature?

    def link(edge)
      @edges << edge
      edge
    end

    def set_as_root!
      if has_parent?
        @parent = nil
      else
        raise "Node is already the root."
      end
      nil
    end

    def remove(id)
      node = @children_hash.delete(id)
      if node.nil?
        raise ArgumentError, 
        "Given ID is not a children of this node."
      end
      @children.delete(node)
      node.set_as_root!
      node
    end

    def remove_all!
      @children.each{|c| c.set_as_root!}
      @children = []
      @children_hash = {}
      nil
    end
  end

  class Edge
    attr_reader :node_a, :node_b
    attr_reader :directed, :direction

    def initialize(node_a, node_b, directed = false, direction = 0)
      @node_a, @node_b = node_a, node_b
      @directed, @direction = directed, direction
    end
  end

end


