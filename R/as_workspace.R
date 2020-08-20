.create_workspace <-
    function(namespace, name)
{
    createWorkspace <- .get_terra()$createWorkspace
    response <- createWorkspace(
        namespace = namespace, name = name,
        attributes = list(description = "New workspace")
    )
    if (status_code(response) >= 400L)
        .stop(response, namespace, name, "create workspace failed")
}

.name_from_path <-
    function(path)
{
    package <- basename(path)
    directory <- dirname(path)
    descr <- tryCatch({
        packageDescription(package, directory, c("Package", "Type"))
    }, warning = function(w) {
        stop("no DESCRIPTION found at '", path, "'", call. = FALSE)
    })

    type <- ifelse(is.na(descr$Type), "Package", descr$Type)
    paste0(type, "-", descr$Package)
}

#' @importFrom utils packageDescription citation
#'
#' @importFrom stats setNames
.package_description <-
    function(path)
{
    package <- basename(path)
    directory <- dirname(path)
    descr <- packageDescription(package, directory)

    if (is.null(descr[["Author"]])) {
        parsed = tools:::.expand_package_description_db_R_fields(unlist(descr))
        descr[["Author"]] <- parsed[["Author"]]
        descr[["Maintainer"]] <- parsed[["Maintainer"]]
    }
    descr[["Authors"]] <- lapply(
        strsplit(descr[["Author"]], "\n")[[1]],
        function(x) setNames(sub(",$", "", trimws(x)), "Author")
    )
    citn <- citation(package, directory)
    descr[["Citation"]] <- format(citn, "text")

    descr
}

#' @importFrom rmarkdown yaml_front_matter
.rmd_vignette_description <-
    function(path)
{
    rmd <- .vignette_paths(path)
    yaml <- lapply(rmd, yaml_front_matter)
    vignette_description <- list(Vignettes = yaml)
    ipynb <- sub("\\.[Rr]md", ".ipynb", basename(rmd))
    for (i in seq_along(vignette_description[[1]]))
        vignette_description[[1]][[i]][["ipynb"]] <- ipynb[[i]]
    titles <- vapply(vignette_description[[1]], `[[`, character(1), "title")
    vignette_description[[1]] <- vignette_description[[1]][order(titles)]

    vignette_description
}

.set_dashboard <-
    function(dashboard, namespace, name)
{
    setAttributes <- .get_terra()$setAttributes
    response <- setAttributes(
        namespace, name,
        list(description = dashboard)
    )
    if (status_code(response) >= 400L)
        .stop(response, namespace, name, "set dashboard failed")
}

#' @rdname as_workspace
#'
#' @title Render R packages as AnVIL workspaces
#'
#' @description `as_workspace()` renders a package source tree (e.g.,
#'     from a git checkout) as an AnVIL workspace.
#'
#' @details Information from the DESCRIPTION file and Rmd YAML files
#'     are used to populate the 'DASHBOARD' tab.
#'
#'     See `?vignettes_to_notebooks()` for details on how vignettes
#'     are processed to notebooks, and the limitations of the current
#'     approach.
#'
#' @param path `character(1)` path to the location of the package
#'     source code.
#'
#' @param namespace `character(1)` AnVIL namespace (billing project)
#'     to be used.
#'
#' @param name `character(1)` AnVIL workspace name or NULL. If NULL,
#'     the workspace name is set to
#'     `"Bioconductor-Package-<pkgname>"`, where `<pkgname>` is the
#'     name of the package (from the DESCRIPTION file) at `path`.
#'
#' @param create `logical(1)` Create a new project?
#'
#' @param update `logical(1)` Update (over-write teh existing
#'     DASHBOARD and any similarly named notebooks) an existing
#'     workspace?  One of `create` and `update` must be TRUE.
#'
#' @return `as_workspace()` returns the URL of the updated workspace,
#'     invisibly.
#'
#' @importFrom whisker whisker.render
#'
#' @export
as_workspace <-
    function(path, namespace, name = NULL, create = FALSE, update = FALSE)
{
    stopifnot(
        .is_scalar_character(path), dir.exists(path),
        .is_scalar_character(namespace),
        .is_scalar_character(name) || is.null(name),
        .is_scalar_logical(create),
        .is_scalar_logical(update)
    )

    if (is.null(name))
        name <- paste0("Bioconductor-", .name_from_path(path))

    ## create / update workspace
    if (create) {
        .create_workspace(namespace, name)
    } else if (!update) {
        stop("'create' a new workspace, or 'update' an existing one")
    }

    add_access(namespace, name)

    ## populate dashboard from package and vignette metadata
    description <- .package_description(path)
    vignette_description <- .rmd_vignette_description(path)
    processing <- list(
        ProcessDate = Sys.time(),
        RVersion = paste0(R.version$major, ".", R.version$minor),
        BioconductorVersion = BiocManager::version()
    )
    data <- c(description, vignette_description, processing)
    data$namespace <- namespace
    data$name <- name

    tmpl_path <-
        system.file(package = "AnVILPublish", "template", "dashboard.tmpl")
    tmpl <- readLines(tmpl_path)
    dashboard <- whisker.render(tmpl, data)
    .set_dashboard(dashboard, namespace, name)

    ## build vignettes and add to workspace
    rmd_paths <- .vignette_paths(path)
    as_notebook(rmd_paths, namespace, name, update = TRUE)

    wkspc <-
        paste0("https://anvil.terra.bio/#workspaces/", namespace, "/", name)
    invisible(wkspc)
}
