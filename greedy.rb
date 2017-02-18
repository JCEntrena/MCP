#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'problem.rb'
require_relative 'algorithm.rb'

include Algorithm

module Clique

  class Greedy

    public

    # Greedy approach to the clique problem.
    # Starting with L = []
    # We choose those indexes with a max amount of connections, connected to all of L, and a random one of those, adding it to L
    # Repeat until no index is found.

    def solve(problem)
      matrix = problem.adjacencyMatrix
      vertices = problem.nVertices
      # Defining clique elements and initial list of possible vertices: [0, 1, _ , vertices-1]
      clique = []
      possible = (0...vertices).to_a

      while !possible.empty?

        # Number of connections of each vertex.
        connections = possible.map{|x| [adjacencies(matrix, x), x]}
        element = connections.max[1]

        # Add new element to clique, delete from possible.
        clique << element+1
        possible.delete(element)

        # Delete vertices not connected to new one.
        possible.delete_if {|x| matrix[x][element] == 0}
      end

      puts "Clique:"
      puts clique.sort
    end

  end

end
