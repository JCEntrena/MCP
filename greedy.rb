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

      until possible.empty?
        # Add new element to clique, delete from possible.
        clique << possible.max_by{|x| adjacencies(x, matrix)}
        # Update possible.
        possible = connected_with_all(clique, matrix)
      end

      # Adjust clique, for indexes
      clique.map!{|x| x+1}

      puts "Clique:"
      puts clique.sort
      puts "Longitud: #{clique.length}"
    end

    # Adaptative approach
    # Second version of Grosso, Locatelli and Della Croce
    def solve2(problem)
      matrix = problem.adjacencyMatrix
      vertices = problem.nVertices
      # Defining clique elements and initial list of possible vertices: [0, 1, _ , vertices-1]
      clique = []
      possible = (0...vertices).to_a
      oneMissing = []
      # Loop variables.
      # When do we start considering swaps, number of swaps, indexes.
      index = 0
      start_swap = 4
      swaps = 0
      max_swaps = 2 * vertices
      last_swap = -1

      # Loop
      until possible.empty?
        if index < start_swap or swaps > max_swaps
          clique << possible.max_by{|x| connections(x, possible, matrix)}
        else
          neighbourhood = possible + oneMissing - [last_swap]
          element = neighbourhood.max_by{|x| connections(x, possible, matrix)}
          # Intentar optimizar en tiempo la forma en la que se comprueba el conjunto en el que está.
          clique << element
          # Delete if swap, update tabu.
          unless possible.include?(element)
            not_connected = clique.select{|x| matrix[x][element] == 0}.first
            clique.delete(not_connected)
            last_swap = not_connected
            swaps += 1
          end
        end
        possible = connected_with_all(clique, matrix)
        oneMissing = missing_one_connection(clique, matrix)
        index += 1
      end

      # Adjust clique, for indexes
      clique.map!{|x| x+1}

      puts "Clique:"
      puts clique.sort
      puts "Longitud: #{clique.length}"

    end

    # Completes a clique using LS
    # Extends clique with operator ADD until no more vertices can be added.
    # Uses random addition, as used in operatorADD.
    def complete_clique(clique, matrix)
      ls = LocalSearch.new
      aux = Array.new(clique)
      element = ls.operatorADD(matrix, aux)
      until element.nil?
        aux << element
        element = ls.operatorADD(matrix, aux)
      end

      aux
    end

  end

end
