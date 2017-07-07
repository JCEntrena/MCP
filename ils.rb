#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'problem.rb'
require_relative 'algorithm.rb'
require_relative 'localsearch.rb'

include Algorithm

module Clique

  class ILS

    def solve(problem, iterations)
      ls = LocalSearch.new
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      vertices = (0...nVert).to_a
      # Random
      @ran = Random.new(28)
      # Initial clique, empty at first.
      clique = []
      best_clique = []
      # Tabu list. For swapping.
      tabu = []

      # Repeat 'iterations' times.
      iterations.times do
        # Perturbation
        # When first used, it provides a random vertex; our starting clique.
        rvertex = vertices[@ran.rand(nVert)]
        while clique.include?(rvertex)
          rvertex = vertices[@ran.rand(nVert)]
        end

        clique.delete_if{|x| matrix[x][rvertex] == 0}
        clique << rvertex

        # Algorithm
        # Initialize lists
        pAdditions = connected_with_all(clique, matrix)
        oneMissing = missing_one_connection(clique, matrix)
        tabu = []

        # Stopping when no additions or swaps could be made.
        until pAdditions.empty? and (oneMissing - tabu).empty?
          if !(pAdditions - tabu).empty?
            # Elección del elemento a añadir: en este caso, tomamos el que tiene más adyacencias.
            element = (pAdditions - tabu).max_by{|x| adjacencies(x, matrix)}
            clique << element

          elsif !(oneMissing - tabu).empty?
            # Elección de los elementos a intercambiar
            # swap = [fuera del clique, en clique]
            swap = ls.operatorSWAP(problem, clique)
            # SWAP
            clique.delete(swap.last)
            clique << swap.first
            # Forbid node to be added again.
            tabu << swap.last

          elsif !pAdditions.empty?
            # Nuevamente elemento con más adyacencias, pero permitimos tabú.
            element = pAdditions.max_by{|x| adjacencies(x, matrix)}
            clique << element
          end

          # Copy if improves.
          if clique.length > best_clique.length
            best_clique = Array.new(clique)
          end

          pAdditions = connected_with_all(clique, matrix)
          oneMissing = missing_one_connection(clique, matrix)

        end

      end

      best_clique.map!{|x| x+1}

      puts 'Clique'
      puts best_clique.sort

    end

  end

end
