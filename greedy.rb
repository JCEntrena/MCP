#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'problem.rb'
require_relative 'algorithm.rb'

include Algorithm

module Clique

  class Greedy

    public

    def initialize
      @rand = Random.new()
    end

    # Greedy approach to the clique problem.
    # Starting with L = []
    # We choose those indexes with a max amount of connections, connected to all of L, and a random among those, adding it to L
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
      clique
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

      # Until swaps start, just adding vertices.
      start_swap.times do |i|
        clique << possible.max_by{|x| connections(x, possible, matrix)}
        possible = connected_with_all(clique, matrix)
        break if possible.empty?
      end

      # Loop until no more additions can be done
      until possible.empty?
        if swaps > max_swaps
          clique << possible.max_by{|x| connections(x, possible, matrix)}
        else
          neighbourhood = possible + oneMissing - [last_swap]
          element = neighbourhood.max_by{|x| connections(x, possible, matrix)}
          # Intentar optimizar en tiempo la forma en la que se comprueba el conjunto en el que está.
          clique << element
          # Delete if swap, update tabu.
          unless possible.include?(element)
            not_connected = clique.find{|x| matrix[x][element] == 0}
            clique.delete(not_connected)
            last_swap = not_connected
            swaps += 1
          end
        end
        possible = connected_with_all(clique, matrix)
        oneMissing = missing_one_connection(clique, matrix)
      end
      clique
    end

    # Completes a clique
    # Extends clique until no more vertices can be added.
    def complete_clique(clique, matrix)
      aux = Array.new(clique)
      element = connected_with_all(aux, matrix).max_by{|x| adjacencies(x, matrix)}
      until element.nil?
        aux << element
        element = connected_with_all(aux, matrix).max_by{|x| adjacencies(x, matrix)}
      end
      aux
    end

    # Completes a clique, using random addition.
    def complete_clique_random(clique, matrix)
      aux = Array.new(clique)
      pAdditions = connected_with_all(aux, matrix)
      until pAdditions.empty?
        aux << pAdditions[@rand.rand(pAdditions.length)]
        pAdditions = connected_with_all(aux, matrix)
      end
      aux
    end

    # Greedy adding random vertex.
    # Mainly for generating initial solution, to be used in other heuristics.
    def solve_random(problem)
      complete_clique_random([], problem.adjacencyMatrix)
    end

    # Greedy repair
    # Deletes nodes until a clique is reached.
    def repair(solution, matrix)
      aux = Array.new(solution)
      until is_clique(aux, matrix)
        element = aux.min_by{|x| adjacencies(x, matrix)}
        aux.delete(element)
      end
      aux
    end

    # Random repair
    def repair_random(solution, matrix)
      aux = Array.new(solution)
      until is_clique(aux, matrix)
        element = aux[@rand.rand(aux.length)]
        aux.delete(element)
      end
      aux
    end

  end

end
