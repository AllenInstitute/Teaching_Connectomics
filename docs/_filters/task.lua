-- Map fenced divs ::: {.task} to a LaTeX `task` tcolorbox in PDF output.
-- In HTML output the div is left untouched and styled by styles.css.
function Div(el)
  if el.classes:includes("task") and FORMAT:match("latex") then
    local out = {}
    table.insert(out, pandoc.RawBlock("latex", "\\begin{task}"))
    for _, b in ipairs(el.content) do
      table.insert(out, b)
    end
    table.insert(out, pandoc.RawBlock("latex", "\\end{task}"))
    return out
  end
end
