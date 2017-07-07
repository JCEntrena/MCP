#!/usr/bin/env ruby
#encoding: utf-8

# Algorithms used for calculations in this project.

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
    list.inject(0) {|sum, element| sum + matrix[node][element]}
  end

  # Check if a node is connected to all the nodes from a list.
  # Compares total sum of adjacencies to list size.
  def is_connected(node, list, matrix)
    list.count {|i| matrix[node][i] == 1} == list.size
  end

  # Returns all nodes connected with given one, as a list of indexes.
  def connected(node, matrix)
    matrix[node].each_index.select{|i| matrix[node][i] == 1}
  end

  # Returns all nodes connected to a list, except those from the list.
  # Used for getting the set of all nodes connected to a cliquex
  def connected_with_all(list, matrix)
    nodes = (0...matrix.size).to_a
    nodes.select!{|y| is_connected(y, list, matrix)}
    nodes - list
  end

  def missing_one_connection(list, matrix)
    nodes = (0...matrix.size).to_a
    nodes.select!{|y| connections(y, list, matrix) == (list.length - 1)}
    nodes
  end

end
