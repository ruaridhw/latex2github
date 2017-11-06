tex2png <- function(math, figure_name, file_name){
  template <- paste0("\\documentclass[preview]{standalone}
                     \\usepackage{amsmath}
                     \\begin{document}
                     \\begin{equation*}", math,"  \\end{equation*}
                     \\end{document}")
  temp_file_tex <- tempfile("math", fileext = ".tex")
  writeLines(template, con = temp_file_tex)
  system(sprintf("pdflatex -shell-escape -output-directory %s %s", dirname(temp_file_tex), temp_file_tex))
  
  # Convert PDFs to PNGs
  temp_file_pdf <- sub(".tex", ".pdf", temp_file_tex)
  on.exit(unlink(c(temp_file_tex, temp_file_pdf)))
  img <- magick::image_read(temp_file_pdf)
  
  # Use figure location from RMarkdown package
  ### Artifical setup
  files_dir <- paste0(file_name, "_files")
  base_pandoc_to <- "markdown_github-ascii_identifiers"
  ### From render.R#L353
  figures_dir <- paste(files_dir, "/figure-", base_pandoc_to, "/", sep = "")
  
  dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)
  outfile <- file.path(figures_dir, figure_name)
  magick::image_write(img, path = outfile, format = "png")
  outfile
}

latex2github <- function(rmdfile) {
  current_dir <- getwd()
  setwd(dirname(rmdfile))
  on.exit(setwd(current_dir))
  rmdfile <- basename(rmdfile)
  # Read Rmd file and match all occurrences of $$...$$
  rmd  <- paste0(readLines(rmdfile), collapse = "\n")
  matches  <- stringr::str_match_all(string = rmd, pattern = "(?s)\\$\\$(.*?)\\$\\$")[[1]]
  math_withquotes <- matches[,1]
  math_noquotes <- matches[,2]
  
  fig_names <- paste0("math", seq_along(math_withquotes), ".png")
  
  # Build standalone latex template per match
  fig_paths <- purrr::pmap_chr(list(math = math_noquotes,
                        figure_name = fig_names,
                        file_name = tools::file_path_sans_ext(rmdfile)),
                        tex2png)
  
  fig_links <- paste0("![](", fig_paths, ")")
  
  rmdtemp <- stringr::str_replace_all(string = rmd,
                                  c("(?s)\\$\\$(.*?)\\$\\$" = fig_links[1],
                                    "(?s)\\$\\$(.*?)\\$\\$" = fig_links[2]))
  writeLines(rmdtemp, con = rmdfile)
  rmarkdown::render(rmdfile, "github_document")
  writeLines(rmd, con = rmdfile)
}

## TODO
## - Bug with 'str_match:str_replace_all' replacing the first match everywhere.
## - 'str_match:str_replace_all' needs to be generalised for fig_links[n]
## - Images are tiny and need to be scaled for the size of the page
