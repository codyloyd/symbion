local function grid(opts)
  local grid = {}
  grid.x = opts and opts.x or 0
  grid.y = opts and opts.y or 0
  grid.w = opts and opts.w or 100
  grid.h = opts and opts.h or 100
  grid.cols = opts and opts.cols or 1
  grid.rows = opts and opts.rows or 1
  grid.margin = opts and opts.margin or 0

  function grid.createCell(opts)
    local row = opts and opts.row or 0
    local col = opts and opts.col or 0
    local rowSpan = opts and opts.rowSpan or 1
    local colSpan = opts and opts.colSpan or 1
    local padding = opts and opts.padding or 0
    if row + rowSpan  > grid.rows then
      error('row out of bounds')
    end
    if col + colSpan > grid.cols then
      error('col out of bounds')
    end
    local cell = {}
    cell.x = grid.w/grid.cols * col + grid.x + grid.margin
    cell.y = grid.h/grid.rows * row + grid.y + grid.margin
    cell.w = grid.w/grid.cols * colSpan - (2*grid.margin)
    cell.h = grid.h/grid.rows * rowSpan - (2*grid.margin)
    function cell.getBorderBox()
      return cell.x, cell.y, cell.w, cell.h
    end
    function cell.getContentBox()
      return cell.x + padding, cell.y + padding, cell.w - (2*padding), cell.h - (2*padding)
    end
    return cell
  end

  return grid
end

return grid
