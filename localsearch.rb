#!/usr/bin/env ruby
#encoding: utf-8


require_relative 'problem.rb'
require_relative 'algorithm.rb'

include Algorithm

module Clique

  class LocalSearch

    public

    def initialize
      @rand = Random.new()
    end

    # Idea from Katayama, Hamamoto, Narihisa (KLS)
    def solve_with_solution(problem, clique, changes)
      matrix = problem.adjacencyMatrix
      vertices = problem.nVertices
      adj = problem.vertAdjacencies
      new_clique = Array.new(clique)
      best_clique = Array.new(new_clique)
      # Initial possible additions and one-missing vertices.
      possible = connected_with_all(new_clique, matrix)
      oneMissing = missing_one_connection(new_clique, matrix)
      # Loop counter, tabu
      index = 0
      tabu = []
      # Loop
      until index > changes
        # Add
        unless possible.empty?
          vertex = possible.max_by{|element| connections(element, possible, matrix)}
          new_clique << vertex
          tabu = []
          # Swap or drop
        else
          # Trying swap.
          # Find gets first that satisfies condition. Saves computation time.
          candidate = oneMissing.shuffle(random: Random.new(index)).find{|element| aux = swap(new_clique, element, matrix);
                                                   one_connected_with_all(aux, matrix)}
          unless candidate.nil?
            new_clique = Array.new(swap(new_clique, candidate, matrix))
            tabu = []
          # Drop
          else
            element = new_clique.min_by{|vertex| adj[vertex]}
            new_clique.delete(element)
            tabu << element
          end
          index += 1
        end
        possible = connected_with_all(new_clique, matrix)
        possible -= tabu
        oneMissing = missing_one_connection(new_clique, matrix)
        # Change if necessary
        if new_clique.length > best_clique.length
          best_clique = Array.new(new_clique)
        end

      end
      best_clique
    end

    # Call one of both versions, as required.
    def solve(problem, changes)
      clique = solve_with_solution(problem, [], changes)
      clique
    end

    # Second algorithm, DLS.
    # Idea from Grosso, Locatelli, Pullan.
    # Random selection.
    def solve_dynamic(problem, clique, changes)
      # Definitions
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      vertices = (0...nVert).to_a
      my_clique = Array.new(clique)
      best_clique = Array.new(clique)
      # Initialize lists
      pAdditions = connected_with_all(my_clique, matrix)
      oneMissing = missing_one_connection(my_clique, matrix)
      tabu = []
      index = 0

      # Stopping when no additions or swaps could be made.
      until (pAdditions.empty? and (oneMissing - tabu).empty?) or index > changes
        if !(pAdditions - tabu).empty?
          # Chooses randomly.
          element = (pAdditions - tabu)[@rand.rand((pAdditions - tabu).length)]
          my_clique << element

        elsif !(oneMissing - tabu).empty?
          # Chooses randomly
          not_connected = (oneMissing - tabu)[@rand.rand((oneMissing - tabu).length)]
          in_clique = my_clique.find{|x| matrix[x][not_connected] == 0}
          # SWAP
          my_clique.delete(in_clique)
          my_clique << not_connected
          # Forbid node to be added again. We add at the beginning of tabu list.
          tabu.unshift(in_clique)
          # Incrementing index.
          index += 1

        elsif !pAdditions.empty?
          # Allow tabu.
          element = pAdditions[@rand.rand(pAdditions.length)]
          my_clique << element
        end

        # Copy if improves.
        if my_clique.length > best_clique.length
          best_clique = Array.new(my_clique)
        end

        pAdditions = connected_with_all(my_clique, matrix)
        oneMissing = missing_one_connection(my_clique, matrix)
        # Limit tabu size
        #tabu = tabu[0..nVert/50]
      end

      best_clique
    end

  end

end
