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
      cvalue = 0
      best_value = 0
      # Defining temperatures
      temperature = 1
      final_temperature = 0.01
      beta = 0.99

      # Possible additions an One Missing init
      pAdditions = (0...nVert).to_a
      oneMissing = []
      index = 0
      until temperature <= final_temperature
        puts index
        index += 1
        neighbourhood = pAdditions + oneMissing
        # Pick 30
        # AJUSTAR
        items = Array.new(neighbourhood)#.shuffle(random: @rand.rand())[0...30]
        # Loop
        items.each do |element|
          # Copy clique
          copy = Array.new(clique)
          copy << element
          unless pAdditions.include?(element)
            not_connected = copy.find{|x| matrix[x][element] == 0}
            copy.delete(not_connected)
          end
          value = value(copy, matrix)
          # puts "Best: #{best_value}. Clique: #{cvalue}. Valor #{value}"
          if value > cvalue
            clique = Array.new(copy)
            cvalue = value
            break
          elsif @rand.rand() < Math.exp((value - cvalue)/temperature)
            clique = Array.new(copy)
            cvalue = value
            break
          end

        end
        if cvalue > best_value
          best_clique = Array.new(clique)
          best_value = cvalue
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
