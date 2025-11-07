# SwiftWithUniformExample

## Installation

### Installing npm packages in UniformDataAndCLI

To install the required npm packages for the Uniform CLI:

1. Navigate to the UniformDataAndCLI directory:
   ```bash
   cd UniformDataAndCLI
   ```

2. Install the npm packages:
   ```bash
   npm install
   ```

This will install the needed Uniform packages and all its dependencies as specified in the `package.json` file.

### Pushing Uniform content into your project

1. Make sure you have an empty Uniform project handy and get the API key (read-write) and project id
2. Create `.env` inside the UniformDataAndCLI directory and add the values there
```bash
UNIFORM_API_KEY=uf17...
UNIFORM_PROJECT_ID=aabb5...
```
3. Run this command in CMD from within the UniformDataAndCLI directory:
```bash
npm run uniform:push
```
Now your Uniform project should be up to date with same content as shown in the video. 

## Run the app

1. Set the Uniform project id and API key in the SwiftWithUniformExample/UniformService.swift file
2. Run the app

It will pull the latest composition from Uniform global API on build. It won't update it when composition is published on Uniform, you will need to restart the app. 