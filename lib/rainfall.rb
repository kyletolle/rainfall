def northern(terrain, row_index, column_index)
  return nil if row_index == 0

  terrain[row_index-1][column_index]
end

def southern(terrain, row_index, column_index)
  return nil if row_index == terrain.length-1

  terrain[row_index+1][column_index]
end

def eastern(terrain, row_index, column_index)
  return nil if column_index == terrain[row_index].length-1

  terrain[row_index][column_index+1]
end

def western(terrain, row_index, column_index)
  return nil if column_index == 0

  terrain[row_index][column_index-1]
end

def all_neighbors(terrain, row_index, column_index)
  return [northern(terrain, row_index, column_index), southern(terrain, row_index, column_index), eastern(terrain, row_index, column_index), western(terrain, row_index, column_index)]
end

def rainFall(terrain)
  depressions = []
  terrain.each.with_index do |row, row_index|
    row.each.with_index do |column, column_index|
      cell_elevation = column
      north, south, east, west = all_neighbors(terrain, row_index, column_index)

      next unless north && south && east && west

      neighbors = [north, south, east, west].uniq
      neighbors.delete(cell_elevation)
      shortest_neighbor = neighbors.min

      next unless shortest_neighbor

      differential = shortest_neighbor - cell_elevation
      depressions << differential if differential > 0
    end
  end

  puts depressions
  depressions.sum
end

