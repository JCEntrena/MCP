#!/usr/bin/env ruby
#encoding: utf-8

# Implementación de técnicas de búsqueda local para trabajar sobre grafos, relativas
# al problema del clique máximo. Implementaremos los operadores ADD, DROP y SWAP.

require_relative 'problem.rb'
require_relative 'algorithm.rb'

include Algorithm

module Clique

  class LocalSearch

    public

    def initialize
      @rand = Random.new(28)
    end

    # Operator add.
    # Given a clique and a problem, return a (random) vertex to add to the clique (maintaining the clique structure).
    def operatorADD(matrix, clique)
      vertices = (0...matrix.length).to_a

      # Possible additions set (PA)
      # Using is_connected function, defined in algorithm.rb.
      pAdditions = vertices.select{ |vertex| is_connected(vertex, clique, matrix) } - clique
      # Check if empty
      if pAdditions.empty?
        return nil
      end
      # Return a random element
      pAdditions[@rand.rand(pAdditions.length)]
    end

    # Operator swap.
    # Given a clique and a problem, swap two vertices maintaining the clique structure.
    def operatorSWAP(matrix, clique)
      vertices = (0...matrix.length).to_a

      # One missing set. Set of vertices connected to all but one nodes in the clique.
      # We assume no vertex in the clique satisfies this condition.
      oneMissing = missing_one_connection(clique, matrix)
      # Check if empty
      if oneMissing.empty?
        return nil
      end

      # Take a random element.
      element = oneMissing[@rand.rand(oneMissing.length)]

      # Take the element not connected to the chosen.
      # Taking the first, as it is a one-element array.
      not_connected = clique.delete_if{|vertex| matrix[vertex][element] == 1}.first
      # Return pair [out-of-clique, in-clique] to swap.
      [element, not_connected]
    end

    def operatorDROP(matrix, clique)
      vertices = (0...matrix.length).to_a
      # Return node in the clique with less connections overall.
      clique.min_by{|vertex| connections(vertex, vertices, matrix)}
    end

    # Idea from Katayama, Hamamoto, Narihisa
    def solve_with_solution(problem, clique, changes)
      matrix = problem.adjacencyMatrix
      vertices = problem.nVertices
      new_clique = Array.new(clique)
      best_clique = Array.new(new_clique)
      # Initial possible additions and one-missing vertices.
      possible = (0...vertices).to_a
      oneMissing = []
      # Loop counter, tabu
      index = 0
      tabu = -1
      # Loop
      until index > changes
        unless possible.empty?
          vertex = possible.max_by{|element| connections(element, possible, matrix)}
          new_clique << vertex
          # Swap or drop
        else
          # Trying swap.
          # Uso find para una técnica del primer mejor. Así, ahorro calcular
          candidate = oneMissing.find{|element| aux = swap(new_clique, element, matrix);
                                                   one_connected_with_all(aux, matrix)}
          unless candidate.nil?
            new_clique = swap(new_clique, candidate, matrix)
          # Drop
          else
            element = operatorDROP(matrix, new_clique)
            new_clique.delete(element)
            tabu = element
          end
          index += 1
        end
        possible = connected_with_all(new_clique, matrix)
        possible.delete(tabu)
        oneMissing = missing_one_connection(new_clique, matrix)
        # Change if necessary
        if new_clique.length > best_clique.length
          best_clique = Array.new(new_clique)
        end
      end
      best_clique
    end

    def solve(problem, changes)
      c = solve_with_solution(problem, [], changes)
      c.map!{|x| x+1}
      puts "Clique:"
      puts c.sort
      puts "Longitud: #{c.length}"
    end

    # Segunda resolución de LS. Más rápida pero peor.
    def solve2(problem, clique, changes)
      # Definitions
      matrix = problem.adjacencyMatrix
      nVert = problem.nVertices
      vertices = (0...nVert).to_a
      my_clique = Array.new(clique)
      best_clique = Array.new(clique)
      # Initialize lists
      pAdditions = connected_with_all(my_clique, matrix)
      oneMissing = missing_one_connection(my_clique, matrix)
      tabu = []
      index = 0

      # Stopping when no additions or swaps could be made.
      # TODO: Comprobar el límite.
      until (pAdditions.empty? and (oneMissing - tabu).empty?) or index > changes
        if !(pAdditions - tabu).empty?
          # Elección del elemento a añadir: en este caso, tomamos el que tiene más adyacencias.
          element = (pAdditions - tabu).max_by{|x| adjacencies(x, matrix)}
          my_clique << element

        elsif !(oneMissing - tabu).empty?
          # Elección de los elementos a intercambiar
          # swap = [fuera del clique, en clique]
          swap = operatorSWAP(matrix, my_clique)
          # SWAP
          my_clique.delete(swap.last)
          my_clique << swap.first
          # Forbid node to be added again.
          tabu << swap.last
          # Incrementing index.
          index += 1

        elsif !pAdditions.empty?
          # Nuevamente elemento con más adyacencias, pero permitimos tabú.
          element = pAdditions.max_by{|x| adjacencies(x, matrix)}
          my_clique << element
        end

        # Copy if improves.
        if my_clique.length > best_clique.length
          best_clique = Array.new(my_clique)
        end

        pAdditions = connected_with_all(my_clique, matrix)
        oneMissing = missing_one_connection(my_clique, matrix)
        # Limit tabu size
        tabu = tabu[0..nVert/10]
      end

      best_clique
    end



  end

end
