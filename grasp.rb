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
      @rand = Random.new(28)
      @ls = LocalSearch.new
    end

    private

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

    def solve(problem, iterations)
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      best_clique = []
    # Loop
      iterations.times do
        solution = generate_random_solution(problem)
        solution = @ls.solve_with_solution(problem, solution, Math.sqrt(nVert).to_i)
        if solution.length > best_clique.length
          best_clique = Array.new(solution)
        end
      end

      puts "¿Es clique? #{is_clique(best_clique, matrix)}"
      # Adjust clique, for indexes
      best_clique.map!{|x| x+1}

      puts "Clique:"
      puts best_clique.sort
      puts "Longitud: #{best_clique.length}"
    end

  end

end
