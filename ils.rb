#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'problem.rb'
require_relative 'algorithm.rb'
require_relative 'localsearch.rb'

include Algorithm

module Clique

  class ILS

    def solve(problem, iterations)
      # Initial declarations
      @ls = LocalSearch.new
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      vertices = (0...nVert).to_a
      # Random
      @ran = Random.new(28)
      # Limit for LS loop. Only used on swaps
      limit = nVert / 3
      # Initial clique, empty at first.
      clique = []
      best_clique = []

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

        # LS Algorithm
        # Initialize lists
        clique = @ls.solve_with_solution(problem, clique, limit)

        if clique.length > best_clique.length
          best_clique = Array.new(clique)
        end

      end
      # Printing issues
      best_clique.map!{|x| x+1}

      puts 'Clique'
      puts best_clique.sort
      puts "Longitud: #{clique.length}"

    end

  end

end
