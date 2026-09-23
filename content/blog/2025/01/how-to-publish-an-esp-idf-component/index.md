---
title: "How to publish an ESP-IDF component on the Registry"
date: 2025-01-14
showAuthor: false
authors:
  - "pedro-minatel"
tags: ["I2C", "Registry", "Component", "ESP-IDF", "Driver", "Library"]
---

### Publishing the component to the ESP-Registry

Now we have everything needed to read the SHTC3 sensor, we need to publish the component to the Component Registry. To do that, there are 2 ways:

- Manual
- GitHub Action

The manual procedure can be found in the [Publish the Component](https://docs.espressif.com/projects/idf-component-manager/en/latest/guides/packaging_components.html#publish-the-component) section in the documentation.

Alternatively to the manual procedure, we can use GitHub Actions to publish every new version of the component automatically.

On this article, we will focus on the GitHub Action procedure.

#### GitHub Actions

If you are not familiar with GitHub Actions, you can read the [official documentation](https://github.com/features/actions).

In sum, GitHub Action is a continuous integration and continuous delivery (CI/CD) platform that automates workflows right on in your GitHub repository. You can use GitHub Actions in a vast situations and you can automate for example the component publishing process.

#### Workflow

To use the actions, we need to create a folder on the root directory of your component repository, named `.github` (do not forget the dot).

Inside this folder, create another folder named `workflows`. On this folder, two workflow files will be created.

- `build_examples.yml`: This workflow will build the component example.
- `upload_components.yml`: This workflow will upload the component to the registry.

The folder structure will be:

```text
.
.github
└── workflows
    └── build_examples.yml
    └── upload_components.yml
└── shtc3
```

**build_examples.yml**

The build workflow will compile the example with the ESP-IDF version specified in the `idf_ver` and will run when you push to the main branch or create a PR (pull request).

This workflow is important to ensure that the code can be built successfully, preventing any potential issues before uploading the component to the registry.

```yaml
name: 'build'

on:
  push:
    branches:
      - 'main'
  pull_request:
    types: [opened, reopened, synchronize]

jobs:
  build:
    name: build target
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        espidf_target:
          - esp32
          - esp32c3
          - esp32c6
          - esp32h2
          - esp32p4
          - esp32s2
          - esp32s3
        examples_path:
          - 'shtc3/examples/shtc3_read'
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          submodules: 'recursive'
      - name: Build Test Application with ESP-IDF
        uses: espressif/esp-idf-ci-action@v1.1.0
        with:
          esp_idf_version: "latest"
          target: ${{ matrix.espidf_target }}
          path: ${{ matrix.examples_path }}
```

You can modify this workflow as you wish, like adding more examples to be tested, remove targets that you do not need, or adding different ESP-IDF versions to be tested.

**upload_components.yml**

To publish the component, the workflow `upload_component` will process the component by using the [upload-components-ci-action](https://github.com/espressif/upload-components-ci-action).

This workflow will run only when the component is pushed to the main branch. This avoids publishing the component before merging the branch to the main.

An important note is that the action will only publish the component if there is no component published with the same version. This means that you need to change the version in the manifest file before running this workflow.

```yaml
name: Push components to Espressif Component Service

on:
    push:
      branches:
        - main

jobs:
  upload_components:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master

      - name: Upload components to component service
        uses: espressif/upload-components-ci-action@v1
        with:
          directories: >
            shtc3;
          namespace: "<namespace>"
          api_token: ${{ secrets.IDF_COMPONENT_API_TOKEN }}
```

Replace the `namespace` with your GitHub username or organization.

In order to upload the component, you need to provide the API key. This key is a secret and **cannot be public**.

**Create the Action secret**

GitHub has the [secret tokens](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions) manager that you can use in the Actions workflow.

To create the API token, go to [tokens](https://components.espressif.com/settings/tokens/) in the Registry and create a new token with `write:components`scope. Make sure to copy the token and store a copy in a safe place. Once you create the token, you will not be able see the full token later.

Now, on your GitHub repository, create a new secret token with the name `IDF_COMPONENT_API_TOKEN` and add the API token as the secret. This secret will be only accessed by the actions inside your repository.

After everything created, you can push all the files to a branch on your repository, test the workflow run and if all goes green (in the actions tab), you can merge and see your component published.

<figure style="width: 90%; margin: 0 auto; text-align: center;">
    <img
        src="./assets/esp-registry-shtc3.webp"
        alt="ESP-Registry SHTC3 Component"
        title="ESP-Registry SHTC3 Component"
        style="width: 100%;"
    />
    <figcaption>ESP-Registry SHTC3 Component</figcaption>
</figure>

For this article, the published component can be found in the Registry: [SHTC3](https://components.espressif.com/components/pedrominatel/shtc3/)

## Using the component

This is the time for testing the published component. For that, we will use the component published for this article, the [SHTC3](https://components.espressif.com/components/pedrominatel/shtc3/). After your own component is published, you can use the same approach.

On the component page, you will see the command from the `idf.py` to add the component to your project. In this case:

```bash
idf.py add-dependency "pedrominatel/shtc3^1.1.0"
```

Run this command inside a project that you want to add the component. By running this command, a new `idf_component.yml` will be added to your project with the new requirement/dependency for your project.

Now you can set the target and build the example (in case you are using the ESP32-C3):

```bash
idf.py set-target esp32c3
idf.py build flash monitor
```

In the build output in the console, you will note this:

```text
Processing 2 dependencies:
[1/2] pedrominatel/shtc3 (1.1.0)
[2/2] idf (5.4.0)
```

Once you build the project, the build system will automatically download all dependencies to a folder called `managed_components`.

If you are not able to see the dependencies or the `managed_components` folder, you can try:

```bash
idf.py reconfigure
```

Another way is to create a new project based on the component example.

<figure style="width: 90%; margin: 0 auto; text-align: center;">
    <img
        src="./assets/esp-registry-shtc3.webp"
        alt="ESP-Registry SHTC3 Component example"
        title="ESP-Registry SHTC3 Component example"
        style="width: 100%;"
    />
    <figcaption>ESP-Registry SHTC3 Component example</figcaption>
</figure>

```bash
idf.py create-project-from-example "pedrominatel/shtc3^1.1.0:shtc3_read"
```

Set the target, build, and flash.

```bash
cd shtc3_read
idf.py set-target esp32c3
idf.py build flash monitor
```

With this command, a new project based on the example will be created. You can just set the target, configure according to your board GPIO, build and flash.

## Conclusion

Publishing a component is not just about sharing code—it’s about sharing knowledge. When you contribute a component to the registry, you’re helping developers solve challenges and build better solutions. Depending on the impact and adoption of your component, you may gain recognition and appreciation from the developer community.

This article is not just a guide on how to create an I2C component; it’s an encouragement for you to start sharing your work and expertise with others. Every contribution helps build a stronger, more collaborative community.

## Reference

- [ESP-Registry](https://components.espressif.com/)
- [ESP-Registry Documentation](https://docs.espressif.com/projects/idf-component-manager/en/latest/)
- [Compote Documentation](https://docs.espressif.com/projects/idf-component-manager/en/latest/reference/compote_cli.html)
- [Component Examples](https://github.com/espressif/esp-bsp/tree/master/components)
- [My Components](https://components.espressif.com/components?q=ns%3Apedrominatel)
