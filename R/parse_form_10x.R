# This is WAY slower... 5x specifically
# Given a node, returns the node if at the bottom, OR list of children
# otherwise
base_nodes <- function(node) {
  # Scenario 1 - no children elements, return the node (easy)
  if (xml2::xml_length(node) == 0) {
    return(list(node))
  }
  if (xml2::xml_name(node) == 'table') {
    if (xml2::xml_length(node) > 1) {
      row2text <- xml2::xml_text(xml2::xml_children(node)[2])
      if (startsWith(row2text, "PART") | startsWith(row2text, " PART")) {
        nodes <- lapply(xml2::xml_children(node), base_nodes)
        return(unlist(nodes, recursive = F))
      } else {
        return(list(node))
      }
    } else {
      return(list(node))
    }
  }
  children <- xml2::xml_contents(node)
  children <- children[xml2::xml_name(children) != "comment"]
  container.children <- children[!(xml2::xml_name(children) %in% c('a','i',
                                                                   'text',
                                                                   'hr', 'br'))]
  # if no children that are containers, return the node
  if (length(container.children) == 0) {
    return(list(node))
  }
  # if all children are fonts without children, return the node. We wan't treat
  # 'font' as a non-container as some cases the font tags are wrappers.
  if (length(container.children[xml2::xml_name(container.children) != 'font'])
      == 0 &&
      sum(sapply(container.children, xml2::xml_length) > 0) == 0) {
    return(list(node))
  }
  nodes <- lapply(children, base_nodes)

  # an xml node unlists to 2 elements, so if we only have 2 elements when
  # unlisted, there is one node, so return the top node.
  if (length(unlist(nodes)) == 2) {
    return(list(node))
  }
  return(unlist(nodes, recursive = F))
}
