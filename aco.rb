#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'problem.rb'
require_relative 'algorithm.rb'
require_relative 'localsearch.rb'

include Algorithm

module Clique

  class ACO

    def initialize
      @ran = Random.new(28)
    end

    # Simple solver.
    def solve(problem, iterations)
      # Initial declarations
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      vertices = (0...nVert).to_a
      # Pheromone, all starting at the same value.
      pheromone = Array.new(nVert, 1.0/nVert)
      # Decreasing pheromone factor, number of ants.
      beta = 0.9
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
          clique << @ran.rand(1..nVert)
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
            aux = @ran.rand()
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
          pheromone[x] *= (iteration_best.length + nVert) * 1.0 / nVert
        end

      end

      # Adjust clique, for indexes
      best_clique.map!{|x| x+1}

      puts "Clique:"
      puts best_clique.sort
      puts "Longitud: #{best_clique.length}"

    end

    # Second approach: Using more complex techniques.
    # Simmulated annealing + matrix information.
    def solve2(problem, iterations)
      # Initial declarations
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      nEdges = problem.nEdges
      vertices = (0...nVert).to_a
      # Pheromone, all starting at the same value.
      pheromone = Array.new(nVert, 1.0/nVert)
      # Decreasing pheromone factor, number of ants.
      beta = 0.95
      nAnts = 50
      # Decreasing temperature factor
      temperature = 1
      gamma = 0.9
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
          clique << @ran.rand(1..nVert)
          # Get neighbourhood
          pAdditions = connected_with_all(clique, matrix)
          # Repeat until neighbourhodd is empty.
          until pAdditions.empty?
            # Probability. Using temperature * Degree/NumEdges as weight.
            probabilities = pAdditions.map{|x| pheromone[x] + temperature * adjacencies(x, matrix) * 1.0 / nEdges}
            # Sum of probabilities.
            sum = probabilities.inject(:+)
            # Normalization
            probabilities.map!{|x| x*1.0 / sum}
            # Get element depending on probability.
            # Comparo el valor aleatorio entre (0, 1) con el valor de la probabilidad.
            # Si es menor, resto y paso al siguiente.
            aux = @ran.rand()
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
          pheromone[x] *= (iteration_best.length + nVert) * 1.0 / nVert
        end
        # Update temperature
        temperature *= gamma

      end

      # Adjust clique, for indexes
      best_clique.map!{|x| x+1}

      puts "Clique:"
      puts best_clique.sort
      puts "Longitud: #{best_clique.length}"

    end

  end

end
