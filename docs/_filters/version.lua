-- On HTML pages that define a `version`, display it in the title block just
-- below the author byline, styled like Quarto's native title metadata.
-- (PDF shows the version via the cover page + running header instead.)
function Pandoc(doc)
  if not FORMAT:match("html") then return doc end
  local v = doc.meta.version
  if v == nil then return doc end
  local vstr = pandoc.utils.stringify(v)
  local html = '<div class="quarto-title-meta module-version"><div>'
    .. '<div class="quarto-title-meta-heading">Version</div>'
    .. '<div class="quarto-title-meta-contents"><p>' .. vstr .. '</p></div>'
    .. '</div></div>'
  table.insert(doc.blocks, 1, pandoc.RawBlock('html', html))
  return doc
end
