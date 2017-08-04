#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'problem.rb'
require_relative 'algorithm.rb'
require_relative 'greedy.rb'

include Algorithm

module Clique

  class SA

    def initialize
      @rand = Random.new(28)
      @greedy = Greedy.new
    end

    # Simple SA
    # Idea propia
    # Toma como entorno C0 y C1.
    def solve(problem)
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      # Defining clique elements and initial list of possible vertices: [0, 1, _ , vertices-1]
      clique = []
      best_clique = []
      cvalue = 0
      best_length = 0
      # Defining temperatures
      temperature = 1
      final_temperature = 0.01
      beta = 0.99
      # Possible additions an One Missing init
      pAdditions = (0...nVert).to_a
      oneMissing = []
      # Loop
      until temperature <= final_temperature
        # Neighbourhood
        neighbourhood = []
        pAdditions.each{|x| neighbourhood << add(clique, x)}
        oneMissing.each do |element|
          neighbourhood << swap(clique, element, matrix)
        end
        clique.each{|x| neighbourhood << drop(clique, x)}
        # Shuffle
        neighbourhood.shuffle!(random: @rand.rand())
        # Loop
        neighbourhood.each do |element|
          value = value(element, matrix)
          # puts "Best: #{best_value}. Clique: #{cvalue}. Valor #{value}"
          if value > cvalue
            clique = Array.new(element)
            cvalue = value
            break
          elsif @rand.rand() < Math.exp((value - cvalue)/temperature)
            clique = Array.new(element)
            cvalue = value
            break
          end

        end
        if best_length < clique.length
          best_clique = Array.new(clique)
          best_length = clique.length
        end
        pAdditions = connected_with_all(clique, matrix)
        oneMissing = missing_one_connection(clique, matrix)

        temperature *= beta
      end
      # Improve best clique, just in case C0 is not empty
      best_clique = @greedy.complete_clique(best_clique, matrix)

      print_solution(best_clique, matrix)
    end

    # Toma como entorno cualquier drop, add (de CUALQUIER vértices) o swap (de cualquier vértice también)
    # Idea de X. Geng, J. Xu, J. Xiao, L. Pan. Adaptada para cambiar cosas.
    def solve2(problem)
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      vertices = (0...nVert).to_a
      # Defining clique elements and initial list of possible vertices: [0, 1, _ , vertices-1]
      graph = []
      best_clique = []
      cvalue = Float::INFINITY
      best_length = 0
      # Defining temperatures
      temperature = 1
      final_temperature = 0.01
      beta = 0.99
      # Loop
      until temperature <= final_temperature
        # Neighbourhood
        neighbourhood = []
        (vertices - graph).each{|x| neighbourhood << add(graph, x);
                                     graph.each{|y| neighbourhood << swap_two(graph, y, x)}}
        graph.each{|x| neighbourhood << drop(graph, x)}
        # Shuffle
        neighbourhood.shuffle!(random: @rand.rand())
        # Loop
        neighbourhood.each do |element|
          value = value2(element, matrix) - element.length
          # puts "Best: #{best_value}. Clique: #{cvalue}. Valor #{value}"
          if value < cvalue
            graph = Array.new(element)
            cvalue = value
            break
          elsif @rand.rand() < Math.exp((value - cvalue)/temperature)
            graph = Array.new(element)
            cvalue = value
            break
          end

        end
        clique = @greedy.repair(graph, matrix)
        if best_length < clique.length
          best_clique = Array.new(clique)
          best_length = clique.length
        end

        temperature *= beta
      end

      best_clique = @greedy.complete_clique(best_clique, matrix)

      print_solution(best_clique, matrix)
    end


  end

end
