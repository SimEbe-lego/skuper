![Databricks](https://img.shields.io/badge/Databricks-D14836?style=for-the-badge&logo=databricks&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

# skuper
## Project Structure

This repository was created based on the `processing_layers` template from [nexus-dab-templates](https://github.com/LEGO/nexus-dab-templates).

```
├── script.sh
├── databricks.yml
├── resources/
└── src/
```

- `script.sh:` Automation script, including GitHub repository creation.
- `databricks.yml:` Bundle configuration with variables, workspaces, and resource references.
- `resources/:` Databricks resources definitions, such as jobs and clusters.
- `src/:` Notebooks and code files.

## :rocket: Quick Start

To deploy this project to GitHub, simply follow these steps:

1. **Authenticate with Databricks:**

   

   You can set up a new profile by running:

   ```bash
   ./script.sh setup "dev"
   ```

   Or log in to an existing one:

   ```bash
   ./script.sh login "dev"
   ```

2. **Update Template:**

   - Update notebooks in `src/processing_layers/`.
   - Adjust template resources in `resources/processing_layers.yml`, if needed.

3. **Deploy Using GitHub:**

   1. Retrieve your Service Principal OAuth tokens for each workspace (environment) using
   the Data Product Registration and Management page here:
   [Get OAuth Tokens](https://baseplate.legogroup.io/catalog/default/tool/onex/data_product)

   2. Set vars in `.env` to retrieved tokens.
   3. Create GitHub repository:
    - **Option 1**: Through the helper script. Run the following in your command line:
      ```bash
      ./script.sh repo
      ```
    - **Option 2**: Manually
        - Create a github repository
        - Push the code. Hint: you can run the code snippet under "…or push an existing repository from the command line" provided in github.
        - Go to `Settings > Environments` and create 3 environments called "dev", "qa" and "prod".
        - Click on one of the created environments and add two secrets named "CLIENT_ID" and "CLIENT_SECRET". Add the 
        values you added to the env files in the previous step.
        - Repeat for all environments.
   4. Trigger the desired workflow in the new repo:
      - `Deployment DEV`: Triggered manually or by `dev/` branch pushes.
      - `Deployment QA`: Triggered by pull requests to `main`.
      - `Deployment PROD`: Triggered on new releases.

      Databricks recommends these triggers, but feel free to adjust them as needed.

## Local Development

To develop your code locally and execute it on a Databricks cluster remotely, follow these steps:

1. Install Python libraries:

   ```bash
   pip3 install --upgrade databricks-connect databricks-sdk
   ```

2. Choose a Databricks cluster from the [dev workspace](https://lego-ssc-dev.cloud.databricks.com/) or create a new one.
3. Add the [cluster ID](https://docs.databricks.com/en/workspace/workspace-details.html#cluster-url-and-id) you selected in the previous step to the `src/sandbox.ipynb` notebook.
4. Run the notebook.

Once the code is ready, feel free to create new notebooks under `src/` or update existing ones. Additionally, you can update or add new resources in `resources/processing_layers.yml`.

### Local Deployment

Deploy this bundle by running:

```bash
./script.sh deploy "dev" "dev"
```

Destroy with:

```bash
./script.sh destroy "dev" "dev"
```
