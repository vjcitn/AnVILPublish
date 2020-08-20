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

Workspace creation or update uses information from the DESCRIPTION file,
and from the YAML metadata at the top of vignettes. It is therefore
worth-while to make sure this information is accurate.

In the DESCRIPTION file, the Title, Version, Authors@R (preferred) or
Author / Maintainer fields, Description, and License fields are used.

In vignettes, the title: and author: name: fields are used; the abstract
is a good candidate for future inclusion.

From package source
-------------------

The one-stop route is to create a workspace from the package source
(e.g., github checkout) directory use `as_workspace()`.

    AnVILPublish::as_workspace(
        "path/to/package",
        "bioconductor-rpci-anvil",     # i.e., billing account
        create = TRUE                  # use update = TRUE for an existing workspace
    )

Use `create = TRUE` to create a new workspace. Use `update = TRUE` to
update (and potentially overwrite) an existing workspace. One of
`create` and `update` must be TRUE. The command illustrated above does
not specify the `name =` argument, so creates or updates a workspace
`"Bioconductor-Package-<pkgname>`, where `<pkgname>` is the name of the
package read from the DESCRIPTION file; provide an explict name to
create or update an arbitrary workspace.

`AnVILPublish::as_workspace()` invokes `as_notebook()` and `add_user()`,
so these steps do not need to be performed ‘by hand’.

From collections of Rmd files
-----------------------------

Some *R* resources, e.g., \[bookdown\]\[\] sites, are not in packages.
These can be processed to tow workspaces with minor modifications.

1.  Add a standard DESCRIPTION file (e.g.,
    `use_this::use_description()`) to the directory containing the
    `.Rmd` files.

2.  Use the `Package:` field to provide a one-word identifier (e.g.,
    `Package: Bioc2020_CNV`) for your material. Add a key-value pair
    `Type: Workshop` or similar. The `Pacakge:` and `Type:` fields will
    will be used to create the workspace name as, in the example here,
    `Bioconductor-Workshop-Bioc2020_CNV`.

3.  Add a ‘yaml’ chunk to the top of each .Rmd file, if not already
    present, including the title and (optionally) name information,
    e.g.,

        ---
        title: "01. Introduction to the workshop"
        author:
        - name: Iman Author
        - name: Imanother Author
        ---

Publish the resources with

    AnVILPublish::as_workspace(
        "path/to/directory",      # directory containing DESCRIPTION file
        "bioconductor-rpci-anvil",
        create = TRUE
    )

Updating notebooks or workspace permissions
===========================================

These steps are performed automatically by `as_workspace()`, but may be
useful when developing a new workspace or revising existing workspaces.

Updating workspace notebooks from vignettes
-------------------------------------------

Transforming vignettes to notebooks may require several iterations, and
is available as a separate operation. Use `update = FALSE` to create
local copies for preview.

    AnVIL::Publish::as_notebook(
        "paths/to/files.Rmd",
        "bioconductor-rpci-anvil",     # i.e., billing account
        "Bioconductor-Package-Foo",    # Workspace name
        update = FALSE                 # make notebooks, but do not update workspace
    )

The vignette transformation process has several limitations. Only `.Rmd`
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
reduced.

Adding user access credentiials to share the notebook
-----------------------------------------------------

The `"Bioconductor_User"` group can be added to the entities that can
see the workspace. AnVIL users wishing to view the worksppace should be
added to the `Bioconductor_User` group, rather than to the workspace
directly. To add the user group, use

    AnVILPublish::add_user(
        "bioconductor-rpci-anvil",
        "Bioconductor-Package-Foo"
    )

Session info
============

    sessionInfo()

    ## R version 4.0.2 (2020-06-22)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 20.04.1 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.9.0
    ## LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.9.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
    ##  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
    ##  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
    ## [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] compiler_4.0.2  magrittr_1.5    tools_4.0.2     htmltools_0.5.0
    ##  [5] yaml_2.2.1      stringi_1.4.6   rmarkdown_2.3   knitr_1.29     
    ##  [9] stringr_1.4.0   xfun_0.16       digest_0.6.25   rlang_0.4.7    
    ## [13] evaluate_0.14
