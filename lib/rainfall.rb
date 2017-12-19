def generate_topography(terrain)
  terrain.map.with_index do |row, row_index|
    row.map.with_index do |value, column_index|
      coord = [row_index, column_index]
      cell = {
        coord: coord,
        elevation: value,
        edge?: (row_index == terrain.length-1) ||
                   (column_index == row.length-1),
      }
    end
  end
  .tap do |topo|
    def topo.coords_visited
      @coords_visited ||= []
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
  return [northern(topo, coord), southern(topo, coord), eastern(topo, coord), western(topo, coord)]
end

def new_lake(cell)
  {
    cells: [cell],
    drains_to_ocean: false,
    height: 0
  }
end

def build_lake(topo, lake, cell)
  return unless cell

  already_visited_this_cell = topo.coords_visited.include?(cell[:coord])
  return if already_visited_this_cell

  topo.coords_visited << cell[:coord]

  return if cell[:elevation] > lake[:height]

  lake[:cells] << cell

  if cell[:edge?]
    lake[:drains_to_ocean] = true
    return
  end

  neighbors = all_neighbors(topo, cell[:coord])
  north, south, east, west = neighbors

  shortest_elevation = neighbors.compact.map{|n| n[:elevation]}.min
  lake_height_must_change = shortest_elevation > cell[:elevation] && lake[:height] < shortest_elevation
  lake.height = shortest_elevation if lake_height_must_change

  build_lake(topo, lake, north)
  build_lake(topo, lake, south)
  build_lake(topo, lake, east)
  build_lake(topo, lake, west)
end

def rainFall(terrain)
  topo = generate_topography(terrain)

  lakes = []

  topo.each do |row|
    row.each do |cell|
      coord = cell[:coord]

      already_visited_this_cell = topo.coords_visited.include?(coord)
      next if already_visited_this_cell

      topo.coords_visited << coord

      next if cell[:edge?]

      neighbors = all_neighbors(topo, coord)
      north, south, east, west = neighbors

      higher_neighbor = neighbors.compact.find do |neighbor|
        neighbor[:elevation] > cell[:elevation]
      end

      next unless higher_neighbor

      lake = new_lake(cell)

      shortest_neighbor = neighbors
        .compact
        .reject { |neighbor| neighbor[:elevation] == cell[:elevation] }
        .sort{|a,b| a[:elevation] <=> b[:elevation]}
        .last

      lake[:height] =
        shortest_neighbor ? shortest_neighbor[:elevation] : higher_neighbor[:elevation]

      build_lake(topo, lake, north)
      build_lake(topo, lake, south)
      build_lake(topo, lake, east)
      build_lake(topo, lake, west)
    end
  end

  lakes.map do |lake|
    lake[:cells].map do |cell|
      lake[:height] - cell[:elevation]
    end
    .sum
  end
  .sum
end

