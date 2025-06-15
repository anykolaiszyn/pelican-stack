# Pelican Panel Docker Compose Deployment

This repository provides a one-click deployment for [Pelican Panel](https://github.com/pelicanpanel/panel) using Docker Compose.

## Features

- Deploys Pelican Panel and a MariaDB database.
- Uses an internal bridge network for communication between services.
- Utilizes named volumes for persistent data storage.
- Automatically configures required environment variables.
- Includes an optional script to generate a `.env` file.
- Provides health checks for services.
- Compatible with Portainer stack import.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Git

## Quick Start

1. **Clone the repository:**

   You can clone the repository using HTTPS with a Personal Access Token (PAT) or by using SSH.

   **Using HTTPS with a Personal Access Token (PAT):**

   If you don't have a PAT, create one by following the [GitHub documentation on creating a PAT](https://github.com/settings/tokens) with the `repo` scope.

   ```bash
   git clone https://YOUR_USERNAME:YOUR_PAT@github.com/anykolaiszyn/pelican-stack.git
   cd pelican-stack
   ```
   (Replace `YOUR_USERNAME` and `YOUR_PAT` with your GitHub username and Personal Access Token)

   **Alternatively, using SSH:**

   Ensure you have an SSH key added to your GitHub account. You can find instructions in the [GitHub documentation on adding an SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

   ```bash
   git clone git@github.com:anykolaiszyn/pelican-stack.git
   cd pelican-stack
   ```

2. **Initialize environment variables (optional but recommended):**

   The `init.sh` script will create a `.env` file with default values if one doesn't exist. You can customize these values before starting the containers.

   ```bash
   ./scripts/init.sh 
   ```

   Or, on Windows (PowerShell):

   ```powershell
   .\scripts\init.ps1
   ```

   Alternatively, you can manually copy `.env.example` to `.env` and edit it:

   ```bash
   cp .env.example .env
   ```

3. **Start the services:**

   ```bash
   docker compose up -d
   ```

   Pelican Panel will be accessible at `http://localhost:8080` by default.

## Configuration

### Environment Variables

Environment variables are managed in the `.env` file. If this file is not present, default values from `docker-compose.yml` or `.env.example` will be used.

Key variables:

- `PELICAN_PORT`: The external port for Pelican Panel (default: `8080`).
- `DB_DATABASE`: MariaDB database name (default: `pelican`).
- `DB_USERNAME`: MariaDB username (default: `pelicanuser`).
- `DB_PASSWORD`: MariaDB user password (default: `changeme`). **It is strongly recommended to change this.**
- `DB_ROOT_PASSWORD`: MariaDB root password (default: `supersecretpassword`). **It is strongly recommended to change this.**

### Changing Ports

To change the port Pelican Panel runs on:

1. Modify the `PELICAN_PORT` variable in your `.env` file.

   ```env
   PELICAN_PORT=8081
   ```

2. Restart the services:

   ```bash
   docker compose down
   docker compose up -d
   ```

   Pelican Panel will then be accessible at `http://localhost:8081` (or your chosen port).

### Setting Up Admin Account

Once Pelican Panel is running:

1. Open your web browser and navigate to `http://localhost:8080` (or your configured URL).
2. The first time you access the panel, you will be guided through the setup process, which includes creating an administrator account.

### Connecting to an External MariaDB

If you prefer to use an existing or external MariaDB server:

1. **Modify `docker-compose.yml`:**
   - Remove or comment out the `pelican-db` service definition.
   - In the `pelican-panel` service, update the `P_DB_HOST` environment variable to point to your external database host.
   - Ensure `P_DB_PORT`, `P_DB_DATABASE`, `P_DB_USERNAME`, and `P_DB_PASSWORD` in your `.env` file (or directly in `docker-compose.yml` if not using `.env`) are set to match your external database credentials.

   Example `pelican-panel` environment variables for an external DB:

   ```yaml
   environment:
     P_CORE_APP_URL: "http://localhost:${PELICAN_PORT:-8080}"
     P_CORE_TIMEZONE: "UTC"
     P_DB_HOST: "your_external_db_host_or_ip" # Update this
     P_DB_PORT: "3306" # Update if your DB uses a different port
     P_DB_DATABASE: "${DB_DATABASE:-pelican}"
     P_DB_USERNAME: "${DB_USERNAME:-pelicanuser}"
     P_DB_PASSWORD: "${DB_PASSWORD:-changeme}"
     # ... other P_ variables
   ```

2. **Ensure Network Accessibility:**
   - Your Pelican Panel container must be able to reach the external MariaDB server over the network.
   - If your external database is running on the Docker host machine, you might use `host.docker.internal` as the `P_DB_HOST` (on Docker Desktop for Mac/Windows) or the host's IP address.

3. **Restart the services:**

   ```bash
   docker compose down # If pelican-db was previously running
   docker compose up -d pelican-panel # Start only the panel service
   ```

## Helper Scripts

- **`./scripts/init.sh` (Linux/macOS) / `.\scripts\init.ps1` (Windows):**
  - Checks if a `.env` file exists.
  - If not, it copies `.env.example` to `.env` to provide a starting point for your configuration.

## Portainer Stack Import

This `docker-compose.yml` is designed to be self-contained and can be directly used to deploy the stack in Portainer:

1. In Portainer, navigate to "Stacks".
2. Click "Add stack".
3. Choose "Web editor" as the build method.
4. Give your stack a name (e.g., `pelican-panel`).
5. Copy the contents of `docker-compose.yml` from this repository and paste it into the web editor.
6. You can define environment variables directly in Portainer under the "Environment variables" section if you prefer not to use a `.env` file or want to override specific values.
7. Click "Deploy the stack".

## Data Persistence

Named volumes are used to persist data:

- `pelican_data`: Stores Pelican Panel application data.
- `pelican_logs`: Stores Pelican Panel logs.
- `pelican_config`: Stores Pelican Panel configuration files.
- `pelican_db_data`: Stores MariaDB database files.

These volumes are managed by Docker and will persist even if the containers are removed and recreated.

## Labels

The `docker-compose.yml` includes OCI standard labels for better metadata and discovery:

- `org.opencontainers.image.source`
- `org.opencontainers.image.description`
- `org.opencontainers.image.licenses`
- `maintainer`
- `version`

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details (if you add one).
