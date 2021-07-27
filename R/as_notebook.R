#' @importFrom yaml read_yaml
.vignette_paths <-
    function(path)
{
    vignette_path <- file.path(path, "vignettes")
    vignettes <- dir(vignette_path, pattern = "\\.[Rr]md$", full.names = TRUE)
    if (!length(vignettes)) {
        ## workshops, books, etc can have Rmd in the root directory
        vignette_path <- path
        vignettes <-
            dir(vignette_path, pattern = "\\.[Rr]md$", full.names = TRUE)
    }
    if (!length(vignettes))
        stop(
            "unable to find vignettes",
            "\n  path: '", path, "'",
            call. = FALSE
        )
    bookdown_path <- file.path(path, "_bookdown.yml")
    if (!is.null(bookdown_path)) {
        bookdown_rmds <- read_yaml(bookdown_path)$rmd_files
        vignettes[match(bookdown_rmds, basename(vignettes))]
    } else {
        sort(vignettes)
    }
}

#' @importFrom rmarkdown render md_document
.rmd_to_md <-
    function(rmd_paths)
{
    knitr::opts_chunk$set(eval = FALSE)
    vapply(rmd_paths, render, character(1), md_document(), envir = globalenv())
}

#' @importFrom rmarkdown yaml_front_matter
.rmd_to_title <- 
    function(rmd_paths)
{
    titles <- vapply(rmd_paths, function(rmd) {
        if (!is.null(yaml_front_matter(rmd)$title)) {
            yaml_front_matter(rmd)$title
        } else {
            lines = readLines(rmd)
            rmd_headings <- lines[grepl("^#[[:blank:]]+", lines)]
            if (grepl("^#[[:blank:]]\\(PART\\)+", rmd_headings[1])) {
                headings <- rmd_headings[2]
            } else {
                headings <- rmd_headings[1]
            }
            if (length(headings)==0)
                headings <- NA_character_
                ## TODO: rmd file name without .rmd
            headings
        }
    }, character(1))
    sub("^#[[:blank:]]*", "", titles)
}

#' @importFrom utils tail
.md_to_ipynb <-
    function(md_paths)
{
    ipynb_paths <- sub("\\.md", ".ipynb", md_paths)
    for (i in seq_along(md_paths)) {
        system2("notedown", c(md_paths[[i]], "-o", ipynb_paths[[i]]))
        ## FIXME: more robust way to add / update top-level metadata
        txt <- readLines(ipynb_paths[[i]])
        idx <- tail(grep(' "metadata": {},', txt, fixed = TRUE), 1)
        txt[idx] <- paste0(
            ' "metadata": {',
            '  "kernelspec": {',
            '   "display_name": "R",',
            '   "language": "R",',
            '   "name": "ir"',
            '  }',
            '},'
        )
        writeLines(txt, ipynb_paths[[i]])
    }
    ipynb_paths
}

#' @importFrom AnVIL avbucket gsutil_cp
.cp_ipynb_to_notebooks <-
    function(ipynb, namespace, name)
{
    bucket <- avbucket(namespace, name)
    notebooks <- paste0(bucket, "/notebooks/")
    gsutil_cp(ipynb, notebooks)
    paste0(notebooks, basename(ipynb))
}

#' @rdname as_notebook
#'
#' @title Render vignettes as .ipynb notebooks
#'
#' @description `as_notebook()` renders .Rmd vignettes as .ipynb
#'     notebooks, and updates the notebooks in an AnVIL workspace.
#'
#' @details `.Rmd` Vignettes are processed to `.md` using
#'     `rmarkdown::render(..., md_document())`, and then translated to
#'     `.ipynb` using python software called `notedown`; notedown is
#'     available at https://github.com/aaren/notedown.
#'
#'     The translation is not perfect, for instance code chunks marked
#'     as `eval = FALSE` are not marked as such in the python notebook.
#'
#' @param rmd_paths `character()` paths to to Rmd files.
#'
#' @param namespace `character(1)` AnVIL namespace (billing project)
#'     to be used.
#'
#' @param name `character(1)` AnVIL workspace name.
#'
#' @param update `logical(1)` Update (over-write any similarly named
#'     notebooks) an existing workspace? The default (FALSE) creates
#'     notebooks locally, e.g., for previewing via `jupyter notebook
#'     *ipynb`.
#'
#' @return `as_notebook()` returns the paths to the local (if `update
#'     = FALSE`) or the workspace notebooks.
#'
#' @export
as_notebook <-
    function(rmd_paths, namespace, name, update = FALSE)
{
    stopifnot(
        .is_character_n(rmd_paths), all(file.exists(rmd_paths)),
        .is_scalar_character(namespace),
        .is_scalar_character(name),
        .is_scalar_logical(update)
    )

    md <- .rmd_to_md(rmd_paths)
    ipynb <- .md_to_ipynb(md)
    if (update) {
        .cp_ipynb_to_notebooks(ipynb, namespace, name)
    } else {
        message("use 'update = TRUE' to copy notebooks to the workspace")
        ipynb
    }
}
