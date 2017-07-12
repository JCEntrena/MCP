#!/usr/bin/env ruby
#encoding: utf-8

# Algorithms used for calculations in this project.

include Clique

module Algorithm

  public

  # Calculates the degree of a node (number of adjacencies of a node)
  # This is obtained by adding the elements in the row indicated by the node,
  # as 1's represents adjacencies.
  def adjacencies(node, matrix)
    matrix[node].inject(:+)
  end

  # Gives number of connections of a node to a list of nodes
  def connections(node, list, matrix)
    list.inject(0){|sum, element| sum + matrix[node][element]}
  end

  # Check if a node is connected to all the nodes from a list.
  # Compares total sum of adjacencies to list size.
  def is_connected(node, list, matrix)
    list.count{|i| matrix[node][i] == 1} == list.size
  end

  def is_connected_but_one(node, list, matrix)
    list.count{|i| matrix[node][i] == 1} == list.size - 1
  end

  # Returns all nodes connected with given one, as a list of indexes.
  def connected(node, matrix)
    matrix[node].each_index.select{|i| matrix[node][i] == 1}
  end

  # Returns all nodes connected to a list, except those from the list.
  # Used for getting the set of all nodes connected to a clique
  def connected_with_all(list, matrix)
    nodes = (0...matrix.size).to_a
    nodes.select!{|y| is_connected(y, list, matrix)}
    nodes - list
  end

  # Returns all nodes connected to all-but-one nodes in a list.
  # Used for getting the set of all nodes connected to a clique except for one
  def missing_one_connection(list, matrix)
    nodes = (0...matrix.size).to_a
    nodes.select!{|y| is_connected_but_one(y, list, matrix)}
    nodes
  end

  # Value of a clique. Used in objective functions.
  # Value = Size + |C_0| / (Size² + 1)
  def value(clique, matrix)
    # Get C_0
    possible = connected_with_all(clique, matrix)
    # Return value
    clique.length + possible.length / (clique.length**2 + 1.0)
  end

end
