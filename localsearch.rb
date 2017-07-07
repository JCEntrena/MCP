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

  end

end
