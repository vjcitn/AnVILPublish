.vignette_paths <-
    function(path)
{
    vignette_path <- file.path(path, "vignettes")
    vignettes <- dir(vignette_path, pattern = "\\.[Rr]md", full = TRUE)
    sort(vignettes)
}

#' @importFrom rmarkdown render md_document
.rmd_to_md <-
    function(rmd_paths)
{
    md <- vapply(rmd_paths, render, character(1), md_document())
}

.md_to_ipynb <-
    function(md_paths)
{
    ipynb_paths <- sub("\\.md", ".ipynb", md_paths)
    for (i in seq_along(md_paths))
        system2("notedown", c(md_paths[[i]], "-o", ipynb_paths[[i]]))
    ipynb_paths
}

#' @importFrom AnVIL avbucket gsutil_cp
.cp_ipynb_to_notebooks <-
    function(ipynb, namespace, name)
{
    bucket <- avbucket(namespace, name)
    notebooks <- paste0(bucket, "/notebooks/")
    gsutil_cp(ipynb, notebooks)
}

#' @rdname vignettes_to_notebooks
#'
#' @title Render vignettes as .ipynb notebooks
#'
#' @description `vignettes_to_notebooks()` renders .Rmd vignettes as
#'     .ipynb notebooks, and updates the notebooks in an AnVIL
#'     workspace.
#'
#' @details `.Rmd` Vignettes are processed to `.md` using
#'     `rmarkdown::render(..., md_document())`, and then translated to
#'     `.ipynb` using python software called `notedown`; notedown is
#'     available at https://github.com/aaren/notedown.
#'
#'     The translation is not perfect, for instance code chunks marked
#'     as `eval = FALSE` are not marked as such in the python notebook.
#'
#' @param path `character(1)` path to the location of the package
#'     source code.
#'
#' @param namespace `character(1)` AnVIL namespace (billing project)
#'     to be used.
#'
#' @param name `character(1)` AnVIL workspace name.
#'
#' @param create `logical(1)` Create a new project?
#'
#' @param update `logical(1)` Update (over-write any similarly named
#'     notebooks) an existing workspace?  One of `create` and `update`
#'     must be TRUE.
#'
#' @export
vignettes_to_notebooks <-
    function(path, namespace, name, create = FALSE, update = FALSE)
{
    stopifnot(
        .is_scalar_character(path), dir.exists(path),
        .is_scalar_character(namespace),
        .is_scalar_character(name),
        .is_scalar_logical(create),
        .is_scalar_logical(update)
    )

    ## create / update workspace
    if (create)
        .create_workspace(namespace, name)
    if (!create && !update)
        stop("'create' a new workspace, or 'update' an existing one")

    rmd <- .vignette_paths(path)
    md <- .rmd_to_md(rmd)
    ipynb <- .md_to_ipynb(md)
    .cp_ipynb_to_notebooks(ipynb, namespace, name)
}
