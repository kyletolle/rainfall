def generate_topography(terrain)
  terrain.map.with_index do |row, row_index|
    row.map.with_index do |value, column_index|
      coord = [row_index, column_index]
      cell = {
        coord: coord,
        elevation: value,
        edge?: (row_index == 0) ||
                 (row_index == terrain.length-1) ||
                 (column_index == 0) ||
                 (column_index == row.length-1),
      }
    end
  end
  .tap do |topo|
    def topo.coords_visited
      @coords_visited ||= []
    end

    def topo.lakes
      @lakes ||= []
    end
  end
end

def northern(topo, coord)
  row_index = coord[0]
  column_index = coord[1]

  return nil if row_index == 0

  topo[row_index-1][column_index]
end

def southern(topo, coord)
  row_index = coord[0]
  column_index = coord[1]

  return nil if row_index == topo.length-1

  topo[row_index+1][column_index]
end

def eastern(topo, coord)
  row_index = coord[0]
  column_index = coord[1]

  return nil if column_index == topo[row_index].length-1

  topo[row_index][column_index+1]
end

def western(topo, coord)
  row_index = coord[0]
  column_index = coord[1]

  return nil if column_index == 0

  topo[row_index][column_index-1]
end

def all_neighbors(topo, coord)
  [
    northern(topo, coord),
    southern(topo, coord),
    eastern(topo, coord),
    western(topo, coord)
  ]
end

def new_lake(cell)
  {
    cells: [cell],
    drains_to_ocean: false,
    height: 0,
    deepest_depth: 0
  }
end

def shortest_neighbor(neighbors)
end

def build_lake(topo, lake, cell)
  coord = cell[:coord]
  already_visited_this_cell = topo.coords_visited.include?(coord)
  return if already_visited_this_cell
  # puts "    maybe lake: #{coord}"

  topo.coords_visited << coord

  return if cell[:elevation] >= lake[:height]
  # puts "      shorter than lake height"

  neighbors = all_neighbors(topo, coord)
  north, south, east, west = neighbors

  shortest_neighbor = neighbors
    .compact
    .reject { |neighbor| neighbor[:elevation] == lake[:deepest_depth] }
    .sort{|a,b| a[:elevation] <=> b[:elevation]}
    .last

  if shortest_neighbor
    # puts "      shortest neighbor: #{shortest_neighbor}"
    lake_height_must_change = shortest_neighbor[:elevation] > lake[:deepest_depth] && lake[:height] > shortest_neighbor[:elevation]
    # puts "      lake height needs to change? #{lake_height_must_change}"
    lake[:height] = shortest_neighbor[:elevation] if lake_height_must_change
  end

  return if cell[:elevation] > lake[:deepest_depth]
  # puts "      higher than deepest depth"

  build_lake(topo, lake, north) if north
  build_lake(topo, lake, south) if south
  build_lake(topo, lake, east) if east
  build_lake(topo, lake, west) if west

  lake[:cells] << cell

  if cell[:edge?]
    # puts "      drains to ocean"
    lake[:drains_to_ocean] = true
    return
  end
end

def rainFall(terrain)
  topo = generate_topography(terrain)

  topo.each do |row|
    row.each do |cell|
      coord = cell[:coord]
      # puts "cell: #{coord}"

      already_visited_this_cell = topo.coords_visited.include?(coord)
      next if already_visited_this_cell
      # puts "  new"

      topo.coords_visited << coord

      next if cell[:edge?]
      # puts "  not edge"

      neighbors = all_neighbors(topo, coord)
      north, south, east, west = neighbors

      higher_neighbor = neighbors.compact.find do |neighbor|
        neighbor[:elevation] > cell[:elevation]
      end

      next unless higher_neighbor
      # puts "  higher neighbor"

      lake = new_lake(cell)
      topo.lakes << lake
      # puts "  making lake"

      shortest_neighbor = neighbors
        .compact
        .reject { |neighbor| neighbor[:elevation] == cell[:elevation] }
        .sort{|a,b| a[:elevation] <=> b[:elevation]}
        .last

      lake[:height] =
        shortest_neighbor ? shortest_neighbor[:elevation] : higher_neighbor[:elevation]
      # puts "  of height #{lake[:height]}"
      lake[:deepest_depth] = cell[:elevation]

      build_lake(topo, lake, north) if north
      build_lake(topo, lake, south) if south
      build_lake(topo, lake, east) if east
      build_lake(topo, lake, west) if west
    end
  end

  topo.lakes.map do |lake|
    puts "Lake: #{lake}"
    return 0 if lake[:drains_to_ocean]

    lake[:cells].map do |cell|
      puts "  Lake cell: #{cell}"
      # puts "    lake height minus cell elevation: #{lake[:height] - cell[:elevation]}"
      lake[:height] - cell[:elevation]
    end
    .sum
  end
  .sum
end

