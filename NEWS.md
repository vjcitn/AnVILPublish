# AnVILPublish 1.8.0

## New Features

- (v. 1.7.1) Support publication output '.Rmd'

# AnVILPublish 1.4.0

## New Features

- (v. 1.3.2) Support _bookdown.yml -- name and order vignettes

# AnVILPublish 1.2.0

## New Features

- Include README.md on Workspace landing page (thanks Vince Carey).

## Bug Fixes

- `as_workspace()` correctly passes an unboxed 'description' attribute
  when setting the dashboard.

# AnVILPublish 0.0.10

- Add 'best practices' and rationale for Rmarkdown-to-jupyter notebook
  conversion.

# AnVILPublish 0.0.9

- Create a notebook `'00-<<workspace name>>'` to install package /
  book dependencies specified in the original source.
- Don't link to vignettes from the DASHBOARD, since the namespace
  changes in cloned workspaces.
- `as_workspace(..., create = FALSE, update=FALSE)` now evaluates
  code, silently.

# AnVILPublish 0.0.8

- Support collections of Rmd files that are not packages, e.g.,
  bookdown sites.
- Add R / Bioconductor version to dashboard

# AnVILPublish 0.0.7

- Revise Rmd-to-ipynb work flow

  - Don't evaluate code chunks (avoids including output in notebook,
    and side-effects because rmarkdown::render does not start a
    separate process)
  - Insert metadata to use the R kernel. jupytext can do this more
    elegantly, but does from .md renders code chunks and pre-formatted
    rather than evaluation cells, and from .Rmd does not process
    markdown well enough, e.g., not suppporting [foo][]-style links
    when the definition is elsewhere in the document.

# AnVILPublish 0.0.6

- Added a `NEWS.md` file to track changes to the package.
- Extensive interface renaming

  - `as_workspace()` (formerly `package_source_as_workspace()`)
  - `as_notebook()` (formerly `vignettes_to_notebooks()`)
  - `add_access()` (formerly `bioconductor_user_access()`)
