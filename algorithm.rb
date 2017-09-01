#!/usr/bin/env ruby
#encoding: utf-8

# Algorithms used for calculations in this project.

include Clique

module Algorithm

  public

  #############################
  # Add, swap and drop.
  #############################
  # ADD
  def add(clique, vertex)
    aux = Array.new(clique)
    aux << vertex
    aux
  end
  # Swap that finds node to remove.
  # Vertex is not in clique, connected to all but one nodes in clique.
  # We add vertex, remove vertex not connected.
  def swap(clique, vertex, matrix)
    aux = Array.new(clique)
    not_connected = aux.find{|x| matrix[x][vertex] == 0}
    aux.delete(not_connected)
    aux << vertex
    aux
  end
  # Swap two vertices
  # Given vertices in clique and out of clique.
  def swap_two(clique, in_clique, out_clique)
    aux = Array.new(clique)
    aux.delete(in_clique)
    aux << out_clique
    aux
  end
  # DROP
  def drop(clique, vertex)
    aux = Array.new(clique)
    aux.delete(vertex)
    aux
  end

  ###################################
  # General purpose methods.
  ###################################

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

  # Returns true if exists a node connected to all of the list
  def one_connected_with_all(list, matrix)
    nodes = (0...matrix.size).to_a
    nodes -= list
    nodes.each do |x|
      if list.all?{|y| matrix[x][y] == 1}
        return true
      end
    end
    false
  end

  # Value of a clique. Used in objective functions.
  def value(clique, matrix)
    # Get C_0
    possible = connected_with_all(clique, matrix)
    # Return value
    clique.length + possible.length / (matrix.length * 1.0)
  end

  # Value of a subgraph. Returns numbre of edges needed for subgraph to be a clique
  # Value is 0 if subgraph is a clique, greater than 0 otherwise.
  def value2(subgraph, matrix)
    sum = 0
    for i in (0...subgraph.length) do
      for j in (i+1...subgraph.length) do
        sum += (1 - matrix[subgraph[i]][subgraph[j]])
      end
    end
    sum
  end

  # Basic checking method.
  def is_clique(list, matrix)
    # Uniq is here just to avoid repeating nodes. It shouldn't happen in practice.
    if list != list.uniq
      return false
    end
    # Actual checking method.
    list.each do |x|
      list.each do |y|
        if matrix[x][y] == 0
          return false
        end
      end
    end
    true
  end

  # Printing issues. 
  def print_solution(clique, matrix)
    aux = Array.new(clique)
    puts "#{is_clique(aux, matrix)}"
    puts "#{aux.length}"
    STDERR.puts "#{aux}"
    STDERR.puts "#{aux.length}"
  end

end
