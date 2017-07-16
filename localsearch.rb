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
          candidates = oneMissing.select{|element| aux = swap(new_clique, element, matrix);
                                                   pa = connected_with_all(aux, matrix);
                                                   pa.length > 0}
          unless candidates.empty?
            element = candidates.first
            new_clique = swap(new_clique, element, matrix)
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

  end

end
