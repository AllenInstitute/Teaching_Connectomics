-- Render tables as full-grid, write-in tables in PDF output (all cell borders +
-- roomy data rows), using the tabularray `longtblr` environment. All tables in
-- these modules are student answer/data tables, so this applies to every table.
-- (Quarto strips the `.bordered` caption class once tbl-colwidths is consumed,
-- so we can't key on it.) HTML output is left untouched.

local function blocks_to_latex(blocks)
  if not blocks or #blocks == 0 then return "" end
  local s = pandoc.write(pandoc.Pandoc(blocks), "latex")
  return (s:gsub("%s+$", ""))
end

local function row_to_latex(row)
  local cells = {}
  for _, cell in ipairs(row.cells) do
    table.insert(cells, blocks_to_latex(cell.contents))
  end
  return table.concat(cells, " & ")
end

function Table(tbl)
  if not FORMAT:match("latex") then return nil end

  local ncol = #tbl.colspecs

  -- Column widths: use tbl-colwidths if present, else equal columns.
  local coefs, has_w = {}, false
  for _, cs in ipairs(tbl.colspecs) do
    local w = cs[2]
    if type(w) == "number" and w > 0 then
      has_w = true
      table.insert(coefs, math.max(1, math.floor(w * 100 + 0.5)))
    else
      table.insert(coefs, 0)
    end
  end
  local colparts = {}
  for i = 1, ncol do
    local c = coefs[i]
    if (not has_w) or c == 0 then c = 1 end
    table.insert(colparts, "X[" .. c .. ",l]")
  end
  local colspecstr = table.concat(colparts, "")

  -- Collect header rows then body rows.
  local lines = {}
  for _, r in ipairs(tbl.head.rows) do
    table.insert(lines, row_to_latex(r))
  end
  local nhead = #tbl.head.rows
  for _, body in ipairs(tbl.bodies) do
    for _, r in ipairs(body.body) do
      table.insert(lines, row_to_latex(r))
    end
  end

  local opts = "width=\\linewidth, colspec={" .. colspecstr .. "}, hlines, vlines, rowsep=3pt"
  if nhead >= 1 then
    opts = opts .. ", row{" .. (nhead + 1) .. "-Z}={ht=8mm}"
  end

  local latex = "{\\small\n\\begin{longtblr}{" .. opts .. "}\n"
    .. table.concat(lines, " \\\\\n")
    .. "\n\\end{longtblr}}"
  return pandoc.RawBlock("latex", latex)
end
