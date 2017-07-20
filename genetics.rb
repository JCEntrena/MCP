#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'problem.rb'
require_relative 'algorithm.rb'
require_relative 'localsearch.rb'

include Algorithm

module Clique

  class Genetics


    def initialize
      @rand = Random.new(28)
      @ls = LocalSearch.new
      @greedy = Greedy.new
    end

    private

    # Inversion mutation
    def mutation(solution)
      aux = Array.new(solution)
      # Mutation points
      p1 = @rand.rand(aux.length)
      p2 = @rand.rand(aux.length)
      # Inversion
      ([p1, p2].min..[p1, p2].max).each do |x|
        if aux.include?(x)
          aux.delete(x)
        else
          aux << x
        end
      end
      aux
    end

    public

    def solve(problem, iterations)
      # Initial declarations
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      # Params.
      size = 50
      pMutation = 0.05
      pCruce = 1
      # Initial random population.
      population = []
      size.times do
        population << @greedy.solve_random(problem)
      end
      # Best clique.
      best_clique = Array.new(population.max_by{|x| x.length})
      # Loop
      iterations.times do |i|
        new_population = []
        # Generate new population
        until population.empty?
          # Parents
          parent1 = population.delete_at(@rand.rand(population.length))
          parent2 = population.delete_at(@rand.rand(population.length))
          # Cross
          if @rand.rand() < pCruce
            all = (parent1 + parent2).uniq
            common = parent1.select{|x| parent2.include?(x)}
            not_common = all - common
            # New generation
            son1 = Array.new(common)
            son2 = Array.new(common)
            not_common.each do |x|
              if @rand.rand() < 0.5
                son1 << x
              else
                son2 << x
              end
            end
            # Mutation (inversion) (son1)
            if @rand.rand() < pMutation
              son1 = mutation(son1)
            end
            # Mutation (inversion) (son2)
            if @rand.rand() < pMutation
              son2 = mutation(son2)
            end
            # Repair sons
            son1 = @greedy.repair(son1, matrix)
            son2 = @greedy.repair(son2, matrix)
            # Get two best
            new_population += [parent1, parent2, son1, son2].max_by(2){|x| x.length}
          else
            new_population += [parent1, parent2]
          end
        end
        population = Marshal.load(Marshal.dump(new_population))
        best = population.max_by{|x| x.length}
        # Get new best
        if best.length > best_clique.length
          best_clique = Array.new(best)
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
