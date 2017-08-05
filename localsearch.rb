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

    # Idea from Katayama, Hamamoto, Narihisa
    def solve_with_solution(problem, clique, changes)
      matrix = problem.adjacencyMatrix
      vertices = problem.nVertices
      new_clique = Array.new(clique)
      best_clique = Array.new(new_clique)
      # Initial possible additions and one-missing vertices.
      possible = connected_with_all(new_clique, matrix)
      oneMissing = missing_one_connection(new_clique, matrix)
      # Loop counter, tabu
      index = 0
      tabu = []
      # Loop
      until index > changes
        # Add
        unless possible.empty?
          vertex = possible.max_by{|element| connections(element, possible, matrix)}
          new_clique << vertex
          tabu = []
          # Swap or drop
        else
          # Trying swap.
          # Uso find para una técnica del primer mejor. Así, ahorro calcular.
          candidate = oneMissing.shuffle(random: Random.new(index)).find{|element| aux = swap(new_clique, element, matrix);
                                                   one_connected_with_all(aux, matrix)}
          unless candidate.nil?
            new_clique = Array.new(swap(new_clique, candidate, matrix))
            tabu = []
          # Drop
          else
            element = new_clique.min_by{|vertex| adjacencies(vertex, matrix)}
            new_clique.delete(element)
            tabu << element
          end
          index += 1
        end
        possible = connected_with_all(new_clique, matrix)
        possible -= tabu
        oneMissing = missing_one_connection(new_clique, matrix)
        # Change if necessary
        if new_clique.length > best_clique.length
          best_clique = Array.new(new_clique)
        end

      end
      best_clique
    end

    # Método que llama al anterior para resolver.
    # Puede cambiarse para que use la primera o segunda versión.
    def solve(problem, changes)
      c = solve2(problem, [], changes)
      print_solution(c, problem.adjacencyMatrix)
    end

    # Segunda resolución de LS.
    # Sacado de Grosso, Locatelli, Pullan, del ILS.
    # Usa elección aleatoria, para ganar velocidad.
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
          element = (pAdditions - tabu)[@rand.rand((pAdditions - tabu).length)]
          my_clique << element

        elsif !(oneMissing - tabu).empty?
          # Elección de los elementos a intercambiar
          not_connected = (oneMissing - tabu)[@rand.rand((oneMissing - tabu).length)]
          in_clique = my_clique.find{|x| matrix[x][not_connected] == 0}
          # SWAP
          my_clique.delete(in_clique)
          my_clique << not_connected
          # Forbid node to be added again. We add at the beginning of tabu list.
          tabu.unshift(not_connected)
          # Incrementing index.
          index += 1

        elsif !pAdditions.empty?
          # Nuevamente elemento con más adyacencias, pero permitimos tabú.
          element = pAdditions[@rand.rand(pAdditions.length)]
          my_clique << element
        end

        # Copy if improves.
        if my_clique.length > best_clique.length
          best_clique = Array.new(my_clique)
        end

        pAdditions = connected_with_all(my_clique, matrix)
        oneMissing = missing_one_connection(my_clique, matrix)
        # Limit tabu size
        #tabu = tabu[0..nVert/50]
      end

      best_clique
    end



  end

end
