#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'problem.rb'
require_relative 'algorithm.rb'
require_relative 'localsearch.rb'

include Algorithm

module Clique

  class GRASP

    public

    def initialize
      @rand = Random.new()
      @ls = LocalSearch.new
    end

    private
    # Takes first half of possible nodes, sorted by adjacencies, and chooses randomly among them.
    def generate_random_solution(problem)
      # Initial declarations
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      random_clique = []
      possible = (0...nVert).to_a
      # Loop. Generating random solution
      until possible.empty?
        candidates = possible.sort_by{|x| adjacencies(x, matrix)}[0..possible.length/2]
        random_clique << candidates[@rand.rand(candidates.length)]
        possible = connected_with_all(random_clique, matrix)
      end

      random_clique
    end

    public
    # Resuelve mediante greedy aleatorizado.
    # Idea propia, básica de GRASP.
    def solve(problem, iterations)
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      best_clique = []
      limit = nVert
      # Loop
      iterations.times do
        solution = generate_random_solution(problem)
        solution = @ls.solve2(problem, solution, limit)
        if solution.length > best_clique.length
          best_clique = Array.new(solution)
        end
      end
      best_clique
    end

  end

end
