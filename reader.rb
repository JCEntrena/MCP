#!/usr/bin/env ruby
#encoding: utf-8

require 'singleton'
require_relative 'problem.rb'
require_relative 'greedy.rb'
require_relative 'ils.rb'
require_relative 'aco.rb'
require_relative 'localsearch.rb'
require_relative 'grasp.rb'
require_relative 'simulatedannealing.rb'
require_relative 'genetics.rb'

module Clique

  # This class will be in charge of reading the data directory and
  # creating one Problem for each file stored in it.
  class Reader
    include Singleton
    public

    def initialize
      @problems = Array.new()
    end

    # Reads
    def readerMethod

      Dir.foreach('./data') do |item|
        # Not working over '.' and '..'
        next if item == '.' or item == '..'
        # Working on real data files.
        # Opening the file in data/file
        file = File.new('./data/' + item, "r")
        while (line = file.gets)
          next if line[0] == 'c'
          if line[0] == 'p'
            size = line.split[2].to_i
            edges = line.split[3].to_i
            # Adjacency matrix
            matrix = Array.new(size) {Array.new(size, 0)}
            next
          else
            # Read edges, adjust to start at 0 and change matrix.
            i = line.split[1].to_i - 1
            j = line.split[2].to_i - 1
            matrix[i][j] = 1
            matrix[j][i] = 1
          end
        end
        # Each node is connected to itself.
        matrix.length.times do |i|
          matrix[i][i] = 1
        end
        problem = Problem.new(item, size, edges, matrix)
        @problems << problem

      end

      # Testing
      #@problems.each do |i|
      #    puts i.to_s
      #end

    end

    # Main. Change if necessary.
    def main
      readerMethod
      @solver = LocalSearch.new
      @problems.each do |problem|
        puts problem.name
        STDERR.puts problem.name
        clique = []
        10.times do
          tiempo = Time.now
          new_clique = @solver.solve(problem, problem.nVertices)
          if new_clique.length > clique.length
            clique = Array.new(new_clique)
          end
          puts "#{(Time.now - tiempo)}\n"
        end
        print_solution(clique, problem.adjacencyMatrix)
        puts "\n"
      end

    end
  end

  if __FILE__ == $0
    Reader.instance.main
  end


end
