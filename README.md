# latex2github

Script for rendering RMarkdown documents to GitHub Flavoured Markdown
containing Latex maths. Currently GitHub does not support maths
and so this script renders each math block as a separate image and
replaces these blocks with the relevant link to the image.

This has the advantage of being able to use every Latex package
(ie. CTAN) as all other currently available workarounds
only support a subset of package functionality.

## Usage

```r
library(stringr)
library(magick)
library(purrr)

source("latex2github.R")
latex2github("example/Example.Rmd")
```
