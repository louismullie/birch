module Birch

  class Tree
    attr_accessor :id, :value, :parent, :features
    attr_reader :children, :edges

    def initialize(value, id)
      @value = value
      @id = id
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
      nodes = [node_or_nodes].flatten
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

    def is_leaf?
      @children.empty?
    end

    def is_root?
      @parent.nil?
    end

    def has_children?
      !@children.empty?
    end

    def has_edges?
      !@edges.empty?
    end

    def has_parent?
      !@parent.nil?
    end

    def has_features?
      !@features.empty?
    end

    def has_feature?(feature)
      @features.has_key?(feature)
    end
    alias_method :has?, :has_feature?

    def link(edge)
      @edges << edge
      edge
    end

    def set_as_root!
      @parent = nil
      self
    end

    def remove(id)
      node = @children_hash.delete(id)
      raise(ArgumentError, "Given ID is not a children of this node.") if node.nil?
      @children.delete(node)
      node.set_as_root!
      node
    end

    def remove_all!
      @children.each{|c| c.set_as_root!}
      @children = []
      @children_hash = {}
      self
    end
  end

  class Edge
    attr_reader :node_a, :node_b, :directed, :direction

    def initialize(*args)
      raise(ArgumentError, "Wrong number of arguments.") unless [3, 4].include?(args.size)
      @node_a = args[0]
      @node_b = args[1]
      @directed = args[2]
      @direction = args.size == 4 ? args[3] : nil
    end
  end
end


