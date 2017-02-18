#!/usr/bin/env ruby
#encoding: utf-8

# Algorithms used for calculations in this project.

module Algorithm

  public

  # Calculates the number of adjacencies of a node in the adjacency matrix
  # This is obtained by adding the elements in the row indicated by the node,
  # as 1's represents adjacencies.
  def adjacencies(matrix, node)
    matrix[node].inject(:+)
  end

  # Check if a node is connected to all the nodes from a list.
  # Compares total sum of adjacencies to list size.
  def is_connected(node, list, matrix)
    list.count {|i| matrix[node][i] == 1} != list.size
  end

  # Returns all nodes connected with given one, as a list of indexes.
  def connected(matrix, node)
    matrix[node].each_index.select{|i| matrix[node][i] == 1}
  end

end
