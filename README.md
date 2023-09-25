# Welcome to your CDK Python project!

This is a blank project for CDK development with Python.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

This project is set up like a standard Python project. The initialization
process also creates a virtualenv within this project, stored under the `.venv`
directory. To initialize this project, you need
[PDM](https://pdm.fming.dev/latest/) installed, which you can install into your
Python 3.11 (required), or install with `pipx install pdm`.

Create your new CDK project by running `./cdk-init.sh --language python`, and
any other options you might want. The the `cdk-init.sh` script wraps `cdk init`,
and will automatically

- Create a new CDK project in a temporary directory (`cdk init` insists on an
  empty directory).
- Migrate the requirements to `pyproject.toml`.
- Copy the created project to the current directory.
- Clean up code.
- Check it in to Git.

After running the above script, add and check in the project.

Then, edit the `pyproject.toml` and update the `[project]` metadata, especially
the name and description.

The project comes with formatting, linting, and type-checking tools to ensure
the quality of the code in your CDK project. The tools run under `pre-commit`,
and are also run in CI for pull requests.

- [black](https://black.readthedocs.io/en/stable/) for Python formatting.
- [isort](https://pycqa.github.io/isort/) for canonical import ordering.
- [Ruff](https://beta.ruff.rs/docs/) for linting; replaces flake8 and other
  linters, being a one-stop shop for fast Python code linting.
- [mypy](https://mypy.readthedocs.io/en/stable/index.html) for type checking.
  The AWS CDK Python modules have type annotations that help ensure that you are
  passing the correct parameters.

To initialize the virtual environment and install the Python packages, run:

```
$ pdm install
```

This will also install the pre-commit hooks.

After the init process completes and the virtualenv is created, you can use the
following step to activate your virtualenv. (If you're using a Windows computer,
please work with this project using Linux, under
[WSL2](https://learn.microsoft.com/en-us/windows/wsl/install).)

```
$ eval $(pdm venv activate)
```

At this point you can now synthesize the CloudFormation template for this code.

```
$ cdk synth
```

## Adding dependencies

To add additional dependencies, for example other CDK libraries, just add them
to your `pyproject.toml` file by running the `pdm add` command, specifying the
package name. Example:

```
$ pdm add aws-cdk.aws-codestar-alpha
```

Packages are frozen using the `pdm.lock` file, which you should check in when it
changes. Using this lock file ensures that all development and production use an
exact set of Python packages. Hashes are calculated and checked on package
sources to ensure consistency and safety.

To search for and update to new versions of packages, use `pdm update`. This
will recalculate the dependencies and update `pdm.lock`.

### Add dependencies to pre-commit mypy

For running pre-commit in CI, dependencies also need to be added to the mypy
hook in `.pre-commit-config.yaml`.

Find the section that looks like this, and add the additional dependency:

```yaml
- repo: https://github.com/pre-commit/mirrors-mypy
  rev: "v1.4.1" # Use the sha / tag you want to point at
  hooks:
    - id: mypy
      stages: [manual]
      name: mypy (CI)
      additional_dependencies:
        # Add dependencies that have type data here.
        # At least include the AWS libraries that are in
        # requirements.txt
        - aws-cdk-lib==2.88.0
        - constructs>=10.0.0,<11.0.0
        # This is the line that corresponds to the 'pdm add' command above
        - aws-cdk.aws-codestar-alpha
```

## Useful commands

- `cdk ls` list all stacks in the app
- `cdk synth` emits the synthesized CloudFormation template
- `cdk deploy` deploy this stack to your default AWS account/region
- `cdk diff` compare deployed stack with current state
- `cdk docs` open CDK documentation

Enjoy!
