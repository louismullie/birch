#include <ruby.h>

/* Notes to self:
 * - Unset can be called w/ one param.
 * - Add can be called w/ one param.
 * - Remove should be called only by ID.
 * - Link changed its API.
 */

/*
 * Initialize the node with its value and id.
 * Setup containers for the children, features
 * and dependencies of this node.
 */
static VALUE birch_initialize(VALUE self, VALUE value, VALUE id)
{
	VALUE parent;
  VALUE children;
	VALUE children_hash;
	VALUE features;
	VALUE edges;
	
	parent = Qnil;
  children = rb_ary_new();
	children_hash = rb_hash_new();
	features = rb_hash_new();
	edges = rb_hash_new();
	id = INT2NUM(2);
	
	rb_iv_set(self, "@value", value);
	rb_iv_set(self, "@id", id);
	
  rb_iv_set(self, "@parent", parent);
	rb_iv_set(self, "@children", children);
	rb_iv_set(self, "@children_hash", children_hash);
	rb_iv_set(self, "@features", features);
	rb_iv_set(self, "@edges", edges);
	
  return self;
}

/* Return the root of the tree. */
static VALUE birch_root(VALUE self) {
	VALUE ancestor;
	VALUE parent;
	
	parent = rb_iv_get(ancestor, "@parent");
	
	if (parent == Qnil) {
		return self;
	} else {
		
		ancestor = parent;
		while (ancestor) {
			rb_iv_get(ancestor, "@parent");
			ancestor = rb_iv_get(ancestor, "@parent");
		}
		
		return ancestor;
	}
}

/* Add a child to this node. */
static VALUE birch_add(VALUE self, VALUE child) {
	
	VALUE children;
	VALUE children_hash;
	
	VALUE child_id;
	
  children = rb_iv_get(self, "@children");
	child_id = rb_funcall(child, rb_intern("id"), 0);
	children_hash = rb_iv_get(self, "@children_hash");
	
  rb_funcall(
		children, 
		rb_intern("push"), 
		1, child
	);
	
	rb_funcall(
		children_hash, 
		rb_intern("store"), 
		2, child_id, child
	);
	
	return child;
	
}

/* Return the feature with the supplied name. */
static VALUE birch_get(VALUE self, VALUE feature) {
	if (feature == rb_intern("id")) {
		return rb_iv_get(self, "@id");
	} else if (feature == rb_intern("value")) {
		return rb_iv_get(self, "@value");
	} else {
		return rb_hash_aref(rb_iv_get(self, "@features"), feature);
	}
}

/* Set the feature to the supplied value. */
static VALUE birch_set(VALUE self, VALUE feature, VALUE value) {
  return rb_hash_aset(rb_iv_get(self, "@features"), feature, value);
}

/* Unset a feature. */
static VALUE birch_unset(VALUE self, VALUE feature) {
	return rb_hash_delete(
		rb_iv_get(self, "@features"), 
		feature
	);
}

static VALUE birch_depth(VALUE self) {
  return rb_str_new2("bonjour!");
}

static VALUE birch_size(VALUE self) {
	
	VALUE sum;
	VALUE children;
	VALUE children_len;
	VALUE i;
	
	children = rb_iv_get(self, "@children");
	children_len = RARRAY_LEN(children);
	
	for (i=0; i<children_len; i++) {
		sum += rb_funcall(
			RARRAY_PTR(children)[i], 
			rb_intern("size"), 0
		);
	}
	
	return sum;
	
}

/* Iterate over each children of the node. */
static VALUE birch_each(VALUE self) {

	long i;
	VALUE children;
	children = rb_iv_get(self, "@children");
	
	RETURN_ENUMERATOR(children, 0, 0);
	
	for (i=0; i<RARRAY_LEN(children); i++) {
		rb_yield(RARRAY_PTR(children)[i]);
	}
	 
	return children;
	
}

static VALUE birch_find(VALUE self, VALUE id) {
	
	VALUE children_hash;
	VALUE children;
	VALUE result;
	long i;
	
	children_hash = rb_iv_get(self, "@children_hash");
	result = rb_hash_aget(children_hash, id);
	
	if (result == Qnil) {
		children = rb_iv_get(self, "@children");
		for (i=0; i < RARRAY_LEN(children); i++) {
			result = rb_funcall(
				RARRAY_PTR(children)[i], 
				rb_intern("find"), 1, id
			);
			if (result != Qnil) { return result; }
		}
		return Qnil;
	} else { return result; }
	
}

/* Boolean - is this node's subtree empty? */
static VALUE birch_is_leaf(VALUE self) {
  return !rb_funcall(
		rb_iv_get(self, "@children"), 
		rb_intern("empty?"), 0);
}

/* Boolean - is this node parent-less? */
static VALUE birch_is_root(VALUE self) {
	return (rb_iv_get(self, "@parent") == Qnil); 
}

/* Boolean - does this node have children */
static VALUE birch_has_children(VALUE self) {
  return !rb_funcall(
		rb_iv_get(self, "@children"), 
		rb_intern("empty?"), 0);
}

/* Boolean - does the node have a parent? */
static VALUE birch_has_parent(VALUE self) {
  if (rb_iv_get(self, "@parent") == Qnil) {
		return Qfalse;
	} else {
		return Qtrue;
	}
}

/* Boolean - does the node have edges? */
static VALUE birch_has_edges(VALUE self) {
  return !rb_funcall(
		rb_iv_get(self, "@edges"), 
		rb_intern("empty?"), 0);
}

/* Boolean - does the node have features? */
static VALUE birch_has_features(VALUE self) {
  return !rb_funcall(
		rb_iv_get(self, "@features"), 
		rb_intern("empty?"), 0);
}

/* Boolean - does the node have feature? */
static VALUE birch_has_feature(VALUE self, VALUE feature) {
	VALUE features;
	features = rb_iv_get(self, "@features");
  if (rb_hash_aref(features, feature) == Qnil) {
		return Qfalse;
	} else {
		return Qtrue;
	}
}

static VALUE birch_link(VALUE self, VALUE edge) {
	
	VALUE dependencies;
	dependencies = rb_iv_get(self, "@dependencies");
	
	rb_funcall(
		dependencies, 
		rb_intern("push"), 1,
		edge
	);
	
}

static VALUE birch_set_as_root(VALUE self) {
	rb_iv_set(self, "@parent", Qnil);
	return self;
}

/* Removes a node by ID and returns it */
static VALUE birch_remove(VALUE self, VALUE id) {
	
	VALUE children; 
	VALUE node;
	VALUE children_hash;
	
	rb_funcall(children_hash, rb_intern("delete"), 1, id);
	node = rb_hash_aget(children_hash, node);
	rb_funcall(children, rb_intern("delete"), 1, node);
	
	return node;

}

/* Remove all children and set them as root. */
static VALUE birch_remove_all(VALUE self) {

	long i;
	VALUE children;
	
	children = rb_iv_get(self, "@children");
	
	for (i = 0; i < RARRAY_LEN(children); i++) {
		rb_funcall(RARRAY_PTR(children)[i], rb_intern("set_as_root!"), 0);
	}
	
	rb_iv_set(self, "@children", rb_ary_new());
	rb_iv_set(self, "@children_hash", rb_hash_new());
	
	return self;
}

/* This class is a node for an N-ary tree data structure
 * with a unique identifier, text value, children, features
 * (annotations) and dependencies.
 *
 * This class was partly based on the 'rubytree' gem.
 * RubyTree is licensed under the BSD license and can
 * be found at http://rubytree.rubyforge.org/rdoc/.
 */
void Init_birch(void) {

	VALUE module = rb_define_module("Birch");
  VALUE klass = rb_define_class_under(module, "Tree", rb_cObject);
	
	rb_define_method(klass, "initialize", birch_initialize, 2);
	
	rb_define_method(klass, "root", birch_root, 1);
	rb_define_method(klass, "<<", birch_add, 1);
	rb_define_method(klass, "add", birch_add, 1);
	
	rb_define_method(klass, "[]", birch_get, 1);
	rb_define_method(klass, "get", birch_get, 1);
	
  rb_define_method(klass, "set", birch_set, 2);
	rb_define_method(klass, "unset", birch_set, -1);
	
	rb_define_method(klass, "depth", birch_depth, 0);
	rb_define_method(klass, "size", birch_size, 0);
	
	rb_define_method(klass, "each", birch_each, 0);
	rb_define_method(klass, "find", birch_find, 1);

	rb_define_method(klass, "is_leaf?", birch_is_leaf, 0);
	rb_define_method(klass, "is_root?", birch_is_root, 0);
	
	rb_define_method(klass, "has_parent?", birch_has_parent, 0);
	rb_define_method(klass, "has_children?", birch_has_children, 0);
	rb_define_method(klass, "has_edges?", birch_has_edges, 0);
	rb_define_method(klass, "has_features?", birch_has_features, 1);
	rb_define_method(klass, "has_feature?", birch_has_feature, 1);
	rb_define_method(klass, "has?", birch_has_feature, 1);
	
	rb_define_method(klass, "link", birch_link, 2);
	
	rb_define_method(klass, "set_as_root!", birch_set_as_root, 0);
	rb_define_method(klass, "remove!", birch_remove, 1);
	rb_define_method(klass, "remove_all!", birch_remove, 0);
	
}