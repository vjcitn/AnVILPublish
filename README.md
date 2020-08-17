Introduction
============

This package produces AnVIL workspaces from R packages. An example uses
the new [Gen3](https://github.com/Bioconductor/Gen3) package as a basis
for the
[Bioconductor-Package-Gen3](https://anvil.terra.bio/#workspaces/bioconductor-rpci-anvil/Bioconductor-Package-Gen3)
workspace (permission to access this workspace is required, but there
are no restrictions on granting permission).

Package installation
--------------------

If necessary, install the AnVILPublish library

    if (!"AnVILPublish" %in% rownames(installed.packages()))
        BiocManager::install("Bioconductor/AnVILPublish")

There are only a small number of functions in the package; it is likely
best practice to invoke these using `AnVILPublish::...()` rather than
attaching the package to the search path.

The `gcloud` SDK
----------------

It is necessary to have the [gcloud SDK](https://cloud.google.com/sdk)
available to copy notebook files to the workspace. Test availability
with

    AnVIL::gcloud_exists()

and verify that the account and project are appropriate (consistent with
AnVIL credentials) for use with AnVIL

    AnVIL::gcloud_account()
    AnVIL::gcloud_project()

Note that these be used to set, as well as interrogate, the acount and
project.

`notedown` software
-------------------

Conversion of .Rmd vignettes to .ipynb notebooks uses
[notedown](https://github.com/aaren/notedown) python software. It must
be available from within *R*, e.g.,

    system2("notedown", "--version")

Creating or updating workspaces
===============================

**CAUTION** updating an existing workspace will replace existing content
in a way that cannot be undone – you will lose content!

Workspace creation or update uses information from the package
DESCRIPTION file, and from the YAML metadata at the top of vignettes. It
is therefore worth-while to make sure this information is accurate.

In the DESCRIPTION file, the Title, Version, Authors@R (preferred) or
Author / Maintainer fields, Description, and License fields are used.

In vignettes, the title: and author: name: fields are used; the abstract
is a good candidate for future inclusion.

From package source
-------------------

The one-stop route is to create a workspace from the package source
(e.g., github checkout) directory use `package_source_as_workspace()`.

    package_source_as_workspace(
        "path/to/package",
        "bioconductor-rpci-anvil",     # i.e., billing account
        "Bioconductor-package-Gen3",   # workspace name
        create = TRUE
    )

Use `create = TRUE` to create a new workspace. Use `update = TRUE` to
update (and potentially overwrite) an existing workspace. One of
`create` and `update` must be TRUE.

Transforming vignettes to notebooks may require several iterations, and
is available as a separate operation.

    vignettes_to_notebooks(
        "path/to/package",
        "bioconductor-rpci-anvil",     # i.e., billing account
        "Bioconductor-package-Gen3",   # workspace name
        update = TRUE
    )

The vignette transformation process as several limitations. Only `.Rmd`
vignettes are supported. Currently, the vignette is transformed first to
a markdown document using the `rmarkdown` command
`render(..., md_document())`. The markdown document is then translated
to python notebook using `notedown`.

Because the input to notedown is a plain markdown document, any
annotations on the code chunks (e.g., `eval = FALSE`) have been lost –
it will appear in the notebook that all code chunks are to be evaluated.
This could be very problematic if the unevaluated code chunks were meant
to illustrate destructive actions like file removal.

Because the Rmd document has been evaluated, it includes output from the
evaluated cells. This will likely be confusing to the user. One approach
migth use environment variables to set all cells to `eval = FALSE`
during the rendering phase.

It is likely that some of the limitations of vignette rendering can be
reduded.

Session info
============
