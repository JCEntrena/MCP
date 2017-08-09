#!/usr/bin/env ruby
#encoding: utf-8

module Clique

  # This class will store one problem and its data, making it accesible:
  # Name: name of the file.
  # nVertices: number of vertices of the graph.
  # nEdges: number of edges of the graph.
  # adjacencyMatrix: adjacency matrix. Contains boolean values.
  class Problem

    attr_reader :name
    attr_reader :nVertices
    attr_reader :nEdges
    attr_reader :adjacencyMatrix

    def initialize(name, nVertices, nEdges, matrix)
      @name = name
      @nVertices = nVertices
      @nEdges = nEdges
      @adjacencyMatrix = matrix
    end

    def to_s
      "Nombre del archivo: #{@name}.
       Número de vértices: #{@nVertices}.
       Número de arcos: #{@nEdges}.\n\n"
    end

    def name
      "#{@name}\n"
    end

  end

end
