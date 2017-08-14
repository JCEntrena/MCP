#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'problem.rb'
require_relative 'algorithm.rb'
require_relative 'localsearch.rb'

include Algorithm

module Clique

  class ACO

    def initialize
      @rand = Random.new()
    end

    # Simple solver.
    # Idea propia.
    def solve(problem, iterations)
      # Initial declarations
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      vertices = (0...nVert).to_a
      # Pheromone, all starting at the same value.
      pheromone = Array.new(nVert, 10.0)
      # Decreasing pheromone factor, number of ants.
      beta = 0.925
      nAnts = 50
      # Initial clique, empty at first.
      clique = []
      best_clique = []

      # Loop
      iterations.times do |i|
        # Best clique in this iteration
        iteration_best = []

        nAnts.times do |j|
          clique = []
          # Pick random vertex.
          clique << @rand.rand(1..nVert)
          # Get neighbourhood
          pAdditions = connected_with_all(clique, matrix)
          # Repeat until neighbourhodd is empty.
          until pAdditions.empty?
            probabilities = pAdditions.map{|x| pheromone[x]}
            # Sum of probabilities.
            sum = probabilities.inject(:+)
            # Normalization
            probabilities.map!{|x| x*1.0 / sum}
            # Get element depending on probability.
            # Comparo el valor aleatorio entre (0, 1) con el valor de la probabilidad.
            # Si es menor, resto y paso al siguiente.
            aux = @rand.rand()
            index = 0
            until aux <= probabilities[index]
              aux -= probabilities[index]
              index += 1
            end
            # Get element, add to clique.
            element = pAdditions[index]
            clique << element
            # Get neighbourhood again
            pAdditions = connected_with_all(clique, matrix)
          end

          if clique.length > iteration_best.length
            iteration_best = Array.new(clique)
          end

        end # End ants

        if iteration_best.length > best_clique.length
          best_clique = Array.new(iteration_best)
        end
        # Update pheromone
        # Decreasing
        pheromone.map!{|x| x*beta}
        # Increasing
        iteration_best.each do |x|
          pheromone[x] *= (iteration_best.length * 5.0 + nVert) / nVert
        end

      end

      best_clique
    end

    # Second approach: Using more complex techniques.
    # Simmulated annealing + matrix information.
    # Idea from Xu, Ma, Lei.
    def solve2(problem, iterations)
      # Initial declarations
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      nEdges = problem.nEdges
      adj = problem.vertAdjacencies
      vertices = (0...nVert).to_a
      # Pheromone, all starting at the same value.
      pheromone = Array.new(nVert, 10.0)
      # Decreasing pheromone factor, number of ants.
      beta = 0.925
      nAnts = 50
      # Decreasing temperature factor
      temperature = 1
      gamma = 0.95
      # Initial clique, empty at first.
      clique = []
      best_clique = []

      # Loop
      iterations.times do |i|
        # Best clique in this iteration
        iteration_best = []

        nAnts.times do |j|
          clique = []
          # Pick random vertex.
          clique << @rand.rand(1..nVert)
          # Get neighbourhood
          pAdditions = connected_with_all(clique, matrix)
          # Repeat until neighbourhodd is empty.
          until pAdditions.empty?
            # Sum of pheromones
            sum = pheromone.inject(:+)
            # Probability. Using temperature * Degree/NumEdges as weight.
            probabilities = pAdditions.map{|x| pheromone[x] / sum * 1.0 + temperature * adj[x] * 1.0 / nEdges}
            # Normalization
            sum2 = probabilities.inject(:+)
            probabilities.map!{|x| x*1.0 / sum2}
            # Get element depending on probability.
            # Comparo el valor aleatorio entre (0, 1) con el valor de la probabilidad.
            # Si es menor, resto y paso al siguiente.
            aux = @rand.rand()
            index = 0
            until aux <= probabilities[index]
              aux -= probabilities[index]
              index += 1
            end
            # Get element, add to clique.
            element = pAdditions[index]
            clique << element
            # Get neighbourhood again
            pAdditions = connected_with_all(clique, matrix)
          end

          if clique.length > iteration_best.length
            iteration_best = Array.new(clique)
          end

        end # End ants

        if iteration_best.length > best_clique.length
          best_clique = Array.new(iteration_best)
        end
        # Update pheromone
        # Decreasing
        pheromone.map!{|x| x*beta}
        # Increasing
        iteration_best.each do |x|
          pheromone[x] *= (iteration_best.length * 5.0 + nVert) / nVert
        end
        # Update temperature
        temperature *= gamma
      end
      best_clique
    end

  end

end
