Publishing R / Bioconductor Packages To AnVIL Workspaces
================
true

# Introduction

This package produces AnVIL workspaces from R packages. An example uses
the new [Gen3](https://github.com/Bioconductor/Gen3) package as a basis
for the
[Bioconductor-Package-Gen3](https://anvil.terra.bio/#workspaces/bioconductor-rpci-anvil/Bioconductor-Package-Gen3)
workspace (permission to access this workspace is required, but there
are no restrictions on granting permission).

## Package installation

If necessary, install the AnVILPublish library

``` r
if (!"AnVILPublish" %in% rownames(installed.packages()))
    BiocManager::install("AnVILPublish")
```

There are only a small number of functions in the package; it is likely
best practice to invoke these using `AnVILPublish::...()` rather than
attaching the package to the search path.

## The `gcloud` SDK

It is necessary to have the [gcloud SDK](https://cloud.google.com/sdk)
available to copy notebook files to the workspace. Test availability
with

``` r
AnVIL::gcloud_exists()
```

and verify that the account and project are appropriate (consistent with
AnVIL credentials) for use with AnVIL

``` r
AnVIL::gcloud_account()
AnVIL::gcloud_project()
```

Note that these be used to set, as well as interrogate, the acount and
project.

## `Quarto` software

Conversion of Rmarkdown (`.Rmd`) or Quarto (`.Qmd`) vignettes to Jupyter
(`.ipynb`) notebooks uses [Quarto](https://quarto.org) software. It must
be available from within *R*, e.g.,

``` r
system2("quarto", "--version")
```

The user must determine if they want their vignettes converted or
rendered into Jupyter notebooks. The difference is that `render`
automatically executes *R* code blocks and embeds images, while
`convert` will not.

Use of Python *notedown* for conversion is no longer supported.

# Creating or updating workspaces

**CAUTION** updating an existing workspace will replace existing content
in a way that cannot be undone – you will lose content!

Workspace creation or update uses information from the DESCRIPTION file,
CSV files in inst/tables, and from the YAML metadata at the top of
vignettes. It is therefore worth-while to make sure this information is
accurate.

In the DESCRIPTION file, the Title, Version, Date, <Authors@R>
(preferred) or Author / Maintainer fields, Description, and License
fields are used.

Tables in inst/tables must be CSV files. Individual entries in the CSV
file may contain ‘whisker’ expressions for variable substitution, as
follows:

- `{{ bucket }}`: the bucket location of the (possibly newly create)
  workspace, as returned by `avbucket()`.

Tables are processed first with `whisker.render()` for variable
substitution, and then `readr::read_csv()` and `avtable_import()`.Q

In vignettes, the title: and author: name: fields are used. The abstract
is a good candidate for future inclusion.

## From package source

The one-stop route is to create a workspace from the package source
(e.g., github checkout) directory using `as_workspace()`.

``` r
AnVILPublish::as_workspace(
    "path/to/package",
    "bioconductor-rpci-anvil",     # i.e., billing account
    create = TRUE                  # use update = TRUE for an existing workspace
)
```

Use `create = TRUE` to create a new workspace. Use `update = TRUE` to
update (and potentially overwrite) an existing workspace. One of
`create` and `update` must be TRUE. The command illustrated above does
not specify the `name =` argument, so creates or updates a workspace
`"Bioconductor-Package-<pkgname>`, where `<pkgname>` is the name of the
package read from the DESCRIPTION file; provide an explicit name to
create or update an arbitrary workspace. The option `use_readme = TRUE`
appends a README.md file to the formatted content of DESCRIPTION file.

`AnVILPublish::as_workspace()` invokes `as_notebook()` so this step does
not need to be performed ‘by hand’.

See the command `add_access()`, below, to make the workspace available
to a wider audience.

## From collections of Rmd files

Some *R* resources, e.g., [bookdown](https://bookdown.org/) sites, are
not in packages. These can be processed to workspaces with minor
modifications.

1.  Add a standard DESCRIPTION file (e.g.,
    `use_this::use_description()`) to the directory containing the
    `.Rmd` files.

2.  Use the `Package:` field to provide a one-word identifier (e.g.,
    `Package: Bioc2020_CNV`) for your material. Add a key-value pair
    `Type: Workshop` or similar. The `Pacakge:` and `Type:` fields will
    be used to create the workspace name as, in the example here,
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

``` r
AnVILPublish::as_workspace(
    "path/to/directory",      # directory containing DESCRIPTION file
    "bioconductor-rpci-anvil",
    create = TRUE
)
```

# Updating notebooks or workspace permissions

These steps are performed automatically by `as_workspace()`, but may be
useful when developing a new workspace or revising existing workspaces.

## Updating workspace notebooks from vignettes

Transforming vignettes to notebooks may require several iterations, and
is available as a separate operation. Use `update = FALSE` to create
local copies for preview.

``` r
AnVILPublish::as_notebook(
    "paths/to/files.Rmd",
    "bioconductor-rpci-anvil",     # i.e., billing account
    "Bioconductor-Package-Foo",    # Workspace name
    update = FALSE                 # make notebooks, but do not update workspace
)
```

The vignette transformation process has several limitations. Only `.Rmd`
vignettes are supported. Currently, the vignette is transformed first to
a markdown document using the `rmarkdown` command
`render(..., md_document())`. The markdown document is then translated
to Python notebook using `quarto`.

It is likely that some of the limitations of vignette rendering can be
reduced.

## Adding user access credentials to share the notebook

The `"Bioconductor_User"` group can be added to the entities that can
see the workspace. AnVIL users wishing to view the workspace should be
added to the `Bioconductor_User` group, rather than to the workspace
directly. To add the user group, use

``` r
AnVILPublish::add_access(
    "bioconductor-rpci-anvil",
    "Bioconductor-Package-Foo"
)
```

# Vignette and .Rmd best practices

## Orientation

`.Rmd` files need to be converted to jupyter notebooks. These ‘best
practices’ lead to results that are more likely to be satisfactory, as
outlined here.

## Best practices

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
    process – all cells are presented as *R* code.

## Additional notes on .Rmd conversion

Current best practice is to use [quarto](https://quarto.org) for
conversion of .Rmd to ipynb. Quarto is available on the Bioconductor
docker image, or easily installed on Linux, macOS, or Windows.

Support for conversion using the Python *notedown* module is no longer
supported.

# Session info

``` r
sessionInfo()
```

    ## R version 4.3.0 Patched (2023-05-01 r84362)
    ## Platform: aarch64-apple-darwin21.6.0 (64-bit)
    ## Running under: macOS Monterey 12.6.6
    ## 
    ## Matrix products: default
    ## BLAS:   /Users/ma38727/bin/R-4-3-branch/lib/libRblas.dylib 
    ## LAPACK: /Users/ma38727/bin/R-4-3-branch/lib/libRlapack.dylib;  LAPACK version 3.11.0
    ## 
    ## locale:
    ## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    ## 
    ## time zone: America/New_York
    ## tzcode source: internal
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] compiler_4.3.0  fastmap_1.1.1   cli_3.6.1       tools_4.3.0    
    ##  [5] htmltools_0.5.5 yaml_2.3.7      rmarkdown_2.22  knitr_1.43     
    ##  [9] xfun_0.39       digest_0.6.31   rlang_1.1.1     evaluate_0.21
