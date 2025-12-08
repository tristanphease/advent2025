require "set"

class Vec3
    attr_accessor :x
    attr_accessor :y
    attr_accessor :z

    def initialize(x, y, z)
       @x = x
       @y = y
       @z = z
    end

    def to_s
        "Vec3: [#{@x}, #{@y}, #{@z}]"
    end

    def distance(other)
        xDiff = @x - other.x
        yDiff = @y - other.y
        zDiff = @z - other.z
        Math.sqrt(xDiff ** 2 + yDiff ** 2 + zDiff ** 2)
    end
end

class DistanceIndices
    attr_accessor :distance
    attr_accessor :index1
    attr_accessor :index2

    def initialize(distance, index1, index2)
        @distance = distance
        @index1 = index1
        @index2 = index2
    end

    def to_s
        "DistanceIndices: #{@distance}: [#{@index1}, #{@index2}]"
    end
end

class Graph
    attr_accessor :num_values
    attr_accessor :connectionDictionary

    def initialize(num_values)
        @num_values = num_values
        @connectionDictionary = Hash.new()
    end

    def addConnection(index1, index2)
        # add connection each way
        addConnectionIfMissing(index1, index2)
        addConnectionIfMissing(index2, index1)
    end

    private
    def addConnectionIfMissing(val1, val2)
        if @connectionDictionary.key?(val1)
            existingVal = @connectionDictionary[val1]
            existingVal.push(val2)
        else
            @connectionDictionary[val1] = [val2]
        end
    end

    public
    def getLargestCircuitSizes()
        visitedNodes = Set.new()
        circuitSizes = []
        for i in 0...@num_values do
            if !visitedNodes.include?(i)
                circuitSize = 0
                nodesToCheck = [i]
                while nodesToCheck.length > 0 do
                    node = nodesToCheck.pop()
                    if !visitedNodes.include?(node)
                        circuitSize += 1
                        visitedNodes.add(node)
                        if @connectionDictionary.key?(node)
                            for newNode in @connectionDictionary[node] do
                                if !visitedNodes.include?(newNode)
                                    nodesToCheck.push(newNode)
                                end
                            end
                        end
                    end
                end
                circuitSizes.push(circuitSize)
            end
        end
        circuitSizes.sort().reverse()
    end
end

def get_data(input_file)
    data = []
    IO.foreach(input_file) { |line|
        values = line.split(',')
        if values.length() > 2
            new_vector = Vec3.new(Integer(values[0]),Integer(values[1]),Integer(values[2]))
            data.push(new_vector)
        end
    }
    data
end

def get_distance_indices_shortest(data)
    # get the distance and indices of those
    distance_indices = []
    for i in 0...data.length do
        for j in i + 1...data.length do
            distance = data[i].distance(data[j])
            new_dist_indices = DistanceIndices.new(distance, i, j)
            distance_indices.push(new_dist_indices)
        end
    end
    distance_indices.sort_by { |dist_indices| dist_indices.distance }
end

def main()
    if ARGV.length() > 1 && ARGV[1] == "2"
        data = get_data(ARGV[0])
        distance_indices = get_distance_indices_shortest(data)

        # connect the smallest values onto the graph
        graph = Graph.new(data.length)
        i = 0
        # this is inefficient but it should get the job done
        while graph.getLargestCircuitSizes().length > 1 do
            graph.addConnection(distance_indices[i].index1, distance_indices[i].index2)
            i += 1
        end
        latest_added = distance_indices[i - 1]
        val1 = data[latest_added.index1]
        val2 = data[latest_added.index2]

        x_mul_val = val1.x * val2.x
        puts "x coords multiplied = #{x_mul_val}"
    elsif ARGV.length() > 0
        data = get_data(ARGV[0])
        distance_indices = get_distance_indices_shortest(data)

        # connect the smallest values onto the graph
        graph = Graph.new(data.length)
        num_connections = 1000
        num_circuits = 3
        for i in 0...num_connections do
            graph.addConnection(distance_indices[i].index1, distance_indices[i].index2)
        end

        largest_circuit_sizes = graph.getLargestCircuitSizes()
        # puts "Largest circuit sizes = #{largest_circuit_sizes}"
        value = 1
        for i in 0...num_circuits
            value *= largest_circuit_sizes[i]
        end

        puts "Value = #{value}"

    else
        puts "Pass through input file"
    end
end

main()
