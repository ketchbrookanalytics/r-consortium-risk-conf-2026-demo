# Demo Model Validation Report

## Instructions to Reproduce the Validation Report

We assume that you have [Git](https://git-scm.com/) and [Docker](https://www.docker.com/) installed.

1. Clone this repository to your local machine.
1. Add the `synthetic_credit_data.csv` file at `/data/synthetic_credit_data.csv` (relative to the root of the repository).
1. Open a terminal and `cd` to the working directory of this repository on your local machine.
1. Ensure that Docker is running.
    + E.g., from a terminal, run `docker --version` and ensure it returns a valid Docker version number.
1. Run the following two commands from the terminal:

```bash
docker build -t ketchbrook/risk-demo .
```

The above command builds the Docker image from the specified `Dockerfile`, and tags it with a name you can use later, such as `ketchbrook/risk-demo`.  This will take a few minutes, because it essentially installs all of our dependencies (R, Quarto, etc.).

When the image has finished building, run:

```bash
docker run --rm -v "$(pwd)/data:/project/data:ro" -v "$(pwd)/_output:/project/_output" ketchbrook/risk-demo
```

The above command runs a Docker container based upon the built `ketchbrook/risk-demo` image (containing all of our dependencies) and executes the command at the end of the Dockerfile, which **generates the model validation report in a new directory called `_output/`**.

The middle lines of the above command represent communication between our local filesystem and the container (which by default has no access to your local filesystem).

- `-v "$(pwd)/data:/project/data:ro"` allows the container "Read-only" access to the local folder named `data/` in the current working directory.
- `-v "$(pwd)/_output:/project/_output"` allows the container to write to a folder (which may or may not already exist; if it doesn't exist, it will be created) named `_output/` in the current working directory.






## Structure

This repository contains the following components:

* [.devcontainer/](.devcontainer/) contains files that specify the Docker-based development environment (i.e., while we're working on the project, we can work in the same exact Docker-ized environment that we'll be handing off to the client)
* [assets/](assets/) contains the [Typst](https://quarto.org/docs/output-formats/typst.html) files that help create the report.
    + [typst-template.typ](assets/typst-template.typ) outlines the [Typst template](https://typst.app/docs/tutorial/making-a-template/) that is used to create the report.
    + [typst-show.typ](assets/typst-show.typ) details the mapping of Pandoc metatdata to function arguments in [typst-template.typ](assets/typst-template.typ).
    + [www/](assets/www/) contains the proprietary images we use on the cover page of our reports.
* [qmd/](qmd/) contains the “child” Quarto documents, one for each section in [report.qmd](report.qmd), that contain the majority of the document's content.
* [R/](R/) contains the custom R functions developed by the validation team.
* [renv/](renv/) contains the high-level [{renv}]() infrastructure for R package version management.
* [_quarto.yml](_quarto.yml) specifies the different [options](https://quarto.org/docs/reference/formats/typst.html) Quarto provides for rendering PDF documents, and also passes variables to [typst-show.typ](assets/typst-show.typ) which, in turn, passes values to [typst-template.typ](assets/typst-template.typ).
* [_targets.R](_targets.R) creates the object cache and DAG-style pipeline via [{targets}](https://books.ropensci.org/targets/).
* [Dockerfile](Dockerfile) contains the environment-as-code instructions for creating the Docker image.
* [generate_mock_data.R](generate_mock_data.R) contains a script for creating the `synthetic_credit_data.csv` file in the .gitignored `data/` directory.
* [references.bib](references.bib) contains the BibTex-style citations used in the report.
* [renv.lock](renv.lock) is the {renv}-based lock file that governs the versions of each of the project's R package dependencies.
* [report.qmd](report.qmd) is the "parent" Quarto file for the model validation report
