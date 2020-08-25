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

Vignette and .Rmd best practices
================================

Orientation
-----------

`.Rmd` files need to be converted to jupyter notebooks. Currently there
is not an ‘ideal’ solution, with details listed in the ‘Additional
notes…’ section. Consequently, there are ‘best practices’ that lead to
results that are more likely to be satisfactory, as outlined here.

Best practices
--------------

1.  For packages, make sure the DESCRIPTION file is complete. Use the
    `Authors@R` notation for fully specifying authors. Add a `Date:`
    field indicating date of last modification. Follow other
    Bioconductor best practices, e.g., using and incrementing
    appropriate version numbers.

2.  For collections of vignettes not in a package (e.g., a bookdown
    folder), add a DESCRIPTION file at the top level. An example is

        Package: BCC2020
        Type: Workshop
        Title: R / Bioconductor in the AnVIL Cloud
        Version: 1.0.0
        Authors@R: 
            c(person(
                given = "Martin",
                family = "Morgan",
                role = c("aut", "cre"),
                email = "Martin.Morgan@RoswellPark.org",
                comment = c(ORCID = "0000-0002-5874-8148")
            ),
            person("Nitesh", "Turaga", role = "ctb"),
            person("Lori", "Shepherd", role = "ctb"))
        Description:
            This book contains material for a 2 1/2 hour course offered at the
            Bioinformatics Community Conference 2020. Bioconductor provides
            more than 1900 R packages for the analysis and comprehension of
            high-throughput genomic data. Most users install and run
            Bioconductor on a personal computer or perhaps use an academic
            cluster. Cloud-based solutions are increasing appealing, removing
            the headaches of local installation while providing access to (a)
            better, scalable computing resources; and (b) large-scale
            'consortium' and other reference data sets. This session
            introduces the AnVIL cloud computing environment. We cover use of
            the cloud as a replacement to desktop-style computing; integrating
            workflows for 'upstream' processing of large data resources with
            interactive 'downstream' analysis and comprehension, using Human
            Cell Atlas single-cell datasets as an example; and querying
            cloud-based consortium data for integration with a users own data
            sets.
        License: CC-BY
        Date: 2020-07-17
        Encoding: UTF-8
        LazyData: true
        Roxygen: list(markdown = TRUE)
        RoxygenNote: 7.1.1

    The `Type` and `Package` fields are used to construct the second and
    third elements of the workspace name (in this case,
    `Bioconductor-Workshop-BCC2020`). `Title`, `Version`, `Authors@R`,
    `Description`, `License`, and `Date` fields are used to construct
    the DASHBOARD page.

3.  Start each vignette with ‘yaml’ containing essential metadata about
    the document – title and author(s). Include other information if
    desired, e.g., abstract, (static) date of last modification.

4.  Use a file naming system AND a yaml `title` field that sorts files
    into the order in which the document content is to be presented,
    e.g., using file names `01-Setup.Rmd`, `02-...` and titles (in the
    yaml) `title: "01 Setup"`, … Naming both files and titles in this
    way provides some chance that the Rmd files are presented, or can be
    made to be presented, sensibly across the Bioconductor package
    landing page and Workspace / NOTEBOOK interface.

5.  All code chunks, regardless of annotations such as `eval = FALSE` or
    `echo = FALSE` are converted to visible, evaluated cells in jupyter
    notebooks. Replace code chunks that you do not wish the user to
    evaluate with HTML tags `<pre></pre>`.

6.  Although both Rmarkdown and python notebooks support code chunks in
    multiple languages, there is no support for this in the conversion
    procdess – all cells are presented as *R* code.

Additional notes on .Rmd conversion
-----------------------------------

The current state of affairs with respect to notebook conversion is
imperfect. Conversion is currently a two-step process: Rmarkdown to
markdown, and markdown to ipynb.

-   The conversion from Rmarkdown to markdown is currently accomplished
    with

        knitr::opts_chunk$set(eval=FALSE)
        rmarkdown::render(..., md_document())

    to create a markdown document from the `.Rmd` source.

    This correctly processes the markdown content, including yaml
    metadata, but renders all code chunks identically.

    Using other knitr options may allow, e.g., conditional inclusion of
    code chunks.

-   Use [`notedown`](https://github.com/aaren/notedown) to convert from
    markdown to jupyter notebook, adding metadata to indicate that the
    notebook has an *R* kernel.

Here are some notes on alternative solutions.

-   [`jupytext`](https://github.com/mwouts/jupytext) (version 1.5.1)
    does not exclude yaml from vignettes. It is under active development
    and may mature into a possible alternative.

-   `pandoc` (version 2.10.1) provides a one-step convertion from `.Rmd`
    to .`ipynb`, but code chunks are rendered as pre-formatted text
    rather than evaluable cell.

-   [`notedown`](https://github.com/aaren/notedown) (version 1.5.1) also
    provides one-step conversion, but has difficulty with some markdown.
    For instance, reference-style links `[foo][1]` are only rendered
    correctly when the reference is in the same code chunk as the link.
    The project has not had commits for several years, and has several
    open issues.

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
