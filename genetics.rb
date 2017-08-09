#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'problem.rb'
require_relative 'algorithm.rb'
require_relative 'localsearch.rb'

include Algorithm

module Clique

  class Genetics


    def initialize
      @rand = Random.new()
      @ls = LocalSearch.new
      @greedy = Greedy.new
    end

    private

    # Inversion mutation
    # Generates random range, inverts nodes in range.
    # Based on ideas of Zhang, Wang, Wu, Zhan
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

    # Genetic resolution.
    # Elitist version. Completes sons with greedy approach.
    # Also based on Zhang, Wang, Wu, Zhan work.
    def solve(problem, iterations)
      # Initial declarations
      matrix = problem.adjacencyMatrix
      # Params.
      size = 40
      pMutation = 0.1
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
          # Cross with probability pCruce
          if @rand.rand() < pCruce
            all = (parent1 + parent2).uniq
            common = parent1.select{|x| parent2.include?(x)}
            not_common = all - common
            # New generation
            # Los hijos tendrán a los comunes, y los no comunes se repartirán entre ellos.
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
            # Repair and complete (greedy) sons.
            son1 = @greedy.repair(son1, matrix)
            son1 = @greedy.complete_clique(son1, matrix)
            son2 = @greedy.repair(son2, matrix)
            son2 = @greedy.complete_clique(son2, matrix)
            # Get two best
            new_population += [parent1, parent2, son1, son2].max_by(2){|x| x.length}
          # No cross, parents go to next generation.
          else
            new_population += [parent1, parent2]
          end
        end
        # population = new population. Copying with Marshal, avoiding references issues.
        population = Marshal.load(Marshal.dump(new_population))
        # Update best
        best = population.max_by{|x| x.length}
        # Get new best
        if best.length > best_clique.length
          best_clique = Array.new(best)
        end

      end
      best_clique
    end

    # Memetic
    # Same as genetic, but also uses LS in new population.
    # Basado en el anterior, usando búsqueda local.
    def solve_memetic(problem, iterations)
      # Initial declarations
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      # Params.
      size = 50
      pMutation = 0.1
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
            son1 = @greedy.complete_clique(son1, matrix)
            son2 = @greedy.repair(son2, matrix)
            son2 = @greedy.complete_clique(son2, matrix)
            # Get two best
            new_population += [parent1, parent2, son1, son2].max_by(2){|x| x.length}
          else
            new_population += [parent1, parent2]
          end
        end
        # Local search.
        population = new_population.map{|x| @ls.solve_with_solution(problem, x, nVert/10)}
        # Get best
        best = population.max_by{|x| x.length}
        # Get new best
        if best.length > best_clique.length
          best_clique = Array.new(best)
        end

      end
      best_clique
    end

  end

end
