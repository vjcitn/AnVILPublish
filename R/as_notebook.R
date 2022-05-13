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

    ## use `_bookdown.yml` to order vignettes, if available
    bookdown_path <- file.path(path, "_bookdown.yml")
    if (file.exists(bookdown_path)) {
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

## Extract vignette title from Rmd
#' @importFrom rmarkdown yaml_front_matter
.notebook_title_from_yaml <-
    function(rmd)
{
    ## retrieve title from yaml
    front_matter <- yaml_front_matter(rmd)
    names(front_matter) <- tolower(names(front_matter))
    front_matter$title
}

#' @importFrom utils head
.notebook_title_from_heading <-
    function(rmd)
{
    ## ...or use the first level one heading as title
    lines <- readLines(rmd)
    rmd_headings <- lines[grepl("^#[[:blank:]]+", lines)]

    ## ignore headings starting with '(PART)' (FIXME: is this just a convention?)
    PART_lines <- grepl("^#[[:blank:]]+\\(PART\\)+", rmd_headings)
    title <- head(rmd_headings[!PART_lines], 1L)

    ## remove markdown tag
    sub("^#[[:blank:]]*", "", title)
}

.notebook_title_from_path <-
    function(rmd)
{
    title <- basename(rmd)
    sub("\\.[Rr]md$", "", title)
}

.notebook_titles <-
    function(rmd_paths)
{
    titles <- vapply(rmd_paths, function(rmd) {
        title <- .notebook_title_from_yaml(rmd)
        if (length(title) == 0L)
            title <- .notebook_title_from_heading(rmd)
        if (length(title) == 0L)
            title <- .notebook_title_from_path(rmd)

        title
    }, character(1))
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
.cp_to_cloud_notebooks <-
    function(notebooks, namespace, name)
{
    bucket <- avbucket(namespace, name)
    bucket_notebooks <- paste0(bucket, "/notebooks/")
    gsutil_cp(notebooks, bucket_notebooks)
    paste0(bucket_notebooks, basename(notebooks))
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
#' @param type `character(1)` The type of notebook to be in the
#'     workspace. Must be on of `ipynb`, `rmd`, or `both`.
#'
#' @return `as_notebook()` returns the paths to the local (if `update
#'     = FALSE`) or the workspace notebooks.
#'
#' @export
as_notebook <-
    function(
        rmd_paths, namespace, name, update = FALSE,
        type = c('ipynb', 'rmd', 'both'))
{
    type = match.arg(type)
    stopifnot(
        .is_character_n(rmd_paths), all(file.exists(rmd_paths)),
        .is_scalar_character(namespace),
        .is_scalar_character(name),
        .is_scalar_logical(update)
    )

    if (type == 'ipynb') {
        mds <- .rmd_to_md(rmd_paths)
        notebooks <- .md_to_ipynb(mds)
    } else if (type == 'rmd') {
        notebooks <- rmd_paths
    } else {
        mds <- .rmd_to_md(rmd_paths)
        notebooks <- .md_to_ipynb(mds)
        notebooks <- c(notebooks, rmd_paths)
    }

    if (update) {
        .cp_to_cloud_notebooks(notebooks, namespace, name)
    } else {
        message("use 'update = TRUE' to copy notebooks to the workspace")
        notebooks
    }
}
