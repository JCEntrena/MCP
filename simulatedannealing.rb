#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'problem.rb'
require_relative 'algorithm.rb'

include Algorithm

module Clique

  class SA

    def initialize
      @rand = Random.new(28)
    end

    # Simple SA
    def solve(problem)
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      # Defining clique elements and initial list of possible vertices: [0, 1, _ , vertices-1]
      clique = []
      best_clique = []
      cvalue = Float::INFINITY
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
          not_connected = clique.find{|x| matrix[x][element] == 0}
          neighbourhood << swap(clique, not_connected, element)
        end
        clique.each{|x| neighbourhood << drop(clique, x)}

        neighbourhood.shuffle!(random: @rand.rand())
        # Loop
        neighbourhood.each do |element|
          value = value2(element, matrix) - value(element, matrix)
          # puts "Best: #{best_value}. Clique: #{cvalue}. Valor #{value}"
          if value < cvalue
            clique = Array.new(element)
            cvalue = value
            break
          elsif @rand.rand() < Math.exp((cvalue - value)/temperature)
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

      puts "¿Es clique? #{is_clique(best_clique, matrix)}"
      # Adjust clique, for indexes
      best_clique.map!{|x| x+1}

      puts "Clique:"
      puts best_clique.sort
      puts "Longitud: #{best_clique.length}"
    end


  end

end
