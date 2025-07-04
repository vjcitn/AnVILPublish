% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as_workspace.R
\name{as_workspace}
\alias{as_workspace}
\title{Render R packages as AnVIL workspaces}
\usage{
as_workspace(
  path,
  namespace,
  name = NULL,
  create = FALSE,
  update = FALSE,
  use_readme = FALSE,
  type = c("ipynb", "rmd", "both"),
  quarto = c("render", "convert"),
  colophon_first = TRUE
)
}
\arguments{
\item{path}{\code{character(1)} path to the location of the package
source code.}

\item{namespace}{\code{character(1)} AnVIL namespace (billing project)
to be used.}

\item{name}{\code{character(1)} AnVIL workspace name.}

\item{create}{\code{logical(1)} Create a new project?}

\item{update}{\code{logical(1)} Update (over-write the existing
DASHBOARD and any similarly named notebooks) an existing
workspace?  If neither \code{create} nor \code{update} is TRUE, the code
to create a workspace is run but no output generated; this can
be useful during debugging.}

\item{use_readme}{\code{logical(1)} Defaults to \code{FALSE}; if \code{TRUE} the
content of README.md in package top-level folder is used with
the package \code{DESCRIPTION} version and provenance metadata for
rendering in the workspace 'DASHBOARD'.}

\item{type}{\code{character(1)} The type of notebook to be copied to the
workspace. Must be on of \code{ipynb}, \code{rmd}, or \code{both}. \code{ipynb}
copies only the Jupyter notebook. \code{rmd} copies Rmarkdown and
Quarto vignettes. \code{both} copies both notebooks and vignettes.}

\item{quarto}{\code{character(1)} If the program Quarto is installed,
this parameter indicates whether the .Rmd files will be
rendered or converted.  See vignette for more details.}

\item{colophon_first}{\code{logical(1)} defaults to \code{TRUE}, which is
the legacy behavior.  Only relevant if \code{use_readme} is \code{TRUE}.
If \code{colophon_first} is \code{FALSE}, the information on author
and date, etc. is placed at the bottom of the workspace
\code{DASHBOARD} description component.  When \code{colophon_first} is
\code{FALSE}, the package DESCRIPTION Title is suppressed as the
information is likely redundant with the README.md title.}
}
\value{
\code{as_workspace()} returns the URL of the updated workspace,
invisibly.
}
\description{
\code{as_workspace()} renders a package source tree (e.g.,
from a git checkout) as an AnVIL workspace.
}
\details{
Information from the DESCRIPTION file and Rmd YAML are
used to populate the 'DASHBOARD' tab.  See \code{?as_notebook()} for
details on how vignettes are processed to notebooks.
}
