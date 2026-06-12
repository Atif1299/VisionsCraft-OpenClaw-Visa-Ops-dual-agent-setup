# GCP Migration — OpenClaw for VisionsCraft

Migrate OpenClaw from your Windows laptop to a 24/7 GCP Compute Engine VM.

**Prerequisites:** Laptop Phase 1 tested and working.  
**Project:** `aqueous-scout-474818-q9`  
**Zone:** `europe-west1-b`  
**Docs:** https://docs.openclaw.ai/install/gcp

---

## Step 1 — Create VM

```bash
gcloud config set project aqueous-scout-474818-q9
gcloud services enable compute.googleapis.com

gcloud compute instances create openclaw-gateway \
  --zone=europe-west1-b \
  --machine-type=e2-small \
  --boot-disk-size=20GB \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --tags=openclaw-gateway
```

Use **e2-small** minimum (2 vCPU, 2GB RAM). e2-micro often OOMs during Docker builds.

---

## Step 2 — SSH and install Docker

```bash
gcloud compute ssh openclaw-gateway --zone=europe-west1-b
```

On the VM:

```bash
sudo apt-get update
sudo apt-get install -y git curl ca-certificates
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
exit
```

SSH back in, then verify:

```bash
docker --version
docker compose version
```

---

## Step 3 — Clone OpenClaw and create directories

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
mkdir -p ~/.openclaw ~/.openclaw/workspace
```

---

## Step 4 — Copy state from laptop

From your **Windows laptop** (PowerShell), pack OpenClaw state:

```powershell
$src = "$env:USERPROFILE\.openclaw"
$dest = "c:\Users\dell\OneDrive\Desktop\Openclaw Setup\openclaw-backup"
New-Item -ItemType Directory -Path $dest -Force
Copy-Item "$src\openclaw.json" $dest
Copy-Item "$src\.env" $dest -ErrorAction SilentlyContinue
Copy-Item "$src\workspace" "$dest\workspace" -Recurse
Copy-Item "$src\credentials" "$dest\credentials" -Recurse
Copy-Item "$src\agents" "$dest\agents" -Recurse
```

Upload to VM:

```bash
gcloud compute scp --recurse "c:/Users/dell/OneDrive/Desktop/Openclaw Setup/openclaw-backup/*" \
  openclaw-gateway:~/.openclaw/ --zone=europe-west1-b
```

Or use `gcloud compute scp` per folder from WSL/Git Bash.

---

## Step 5 — Configure Docker environment

On the VM, in the `openclaw` repo root, create `.env`:

```bash
OPENCLAW_IMAGE=openclaw:latest
OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 24)
OPENCLAW_GATEWAY_BIND=lan
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_CONFIG_DIR=/home/$USER/.openclaw
OPENCLAW_WORKSPACE_DIR=/home/$USER/.openclaw/workspace
GOG_KEYRING_PASSWORD=$(openssl rand -hex 32)
XDG_CONFIG_HOME=/home/node/.openclaw
```

Update `~/.openclaw/openclaw.json` gateway section to use the new token.

Create or use the repo's `docker-compose.yml` per official GCP guide (loopback bind recommended):

```yaml
services:
  openclaw-gateway:
    image: ${OPENCLAW_IMAGE}
    build: .
    restart: unless-stopped
    env_file:
      - .env
    environment:
      - HOME=/home/node
      - NODE_ENV=production
      - OPENCLAW_GATEWAY_BIND=${OPENCLAW_GATEWAY_BIND}
      - OPENCLAW_GATEWAY_PORT=${OPENCLAW_GATEWAY_PORT}
      - OPENCLAW_GATEWAY_TOKEN=${OPENCLAW_GATEWAY_TOKEN}
    volumes:
      - ${OPENCLAW_CONFIG_DIR}:/home/node/.openclaw
      - ${OPENCLAW_WORKSPACE_DIR}:/home/node/.openclaw/workspace
    ports:
      - "127.0.0.1:${OPENCLAW_GATEWAY_PORT}:18789"
    command:
      [
        "node",
        "dist/index.js",
        "gateway",
        "--bind",
        "${OPENCLAW_GATEWAY_BIND}",
        "--port",
        "${OPENCLAW_GATEWAY_PORT}",
        "--allow-unconfigured",
      ]
```

---

## Step 6 — Build and launch

```bash
docker compose build
docker compose up -d
docker compose logs -f openclaw-gateway
```

---

## Step 7 — Access Control UI from laptop

```bash
gcloud compute ssh openclaw-gateway --zone=europe-west1-b -- -L 18789:127.0.0.1:18789
```

Open: http://127.0.0.1:18789/?token=YOUR_GATEWAY_TOKEN

Approve browser device if prompted:

```bash
docker compose run --rm openclaw-cli devices list
docker compose run --rm openclaw-cli devices approve <requestId>
```

---

## Step 8 — Re-link WhatsApp (if needed)

If WhatsApp session did not survive migration:

```bash
docker compose run --rm openclaw-cli channels login --channel whatsapp
```

Use Control UI QR handoff (more reliable than terminal screenshot on headless VM).

Verify:

```bash
docker compose run --rm openclaw-cli channels status
```

---

## Step 9 — Verify on GCP

1. Message business WhatsApp from a test phone
2. Confirm Visa responds with VisionsCraft persona
3. Check leads on VM:

```bash
cat ~/.openclaw/workspace/leads/leads.jsonl
```

---

## Maintenance

```bash
# Update OpenClaw
cd ~/openclaw && git pull && docker compose build && docker compose up -d

# View logs
docker compose logs -f openclaw-gateway

# Restart
docker compose restart openclaw-gateway
```

---

## Cost estimate

| Resource | Approx. cost |
|----------|--------------|
| e2-small VM | ~$12/mo |
| 20GB boot disk | ~$2/mo |
| OpenAI API | Usage-based |
| **Total infra** | **~$14/mo** |

---

## Rollback

If GCP migration fails, stop the VM and continue on laptop:

```powershell
openclaw gateway --port 18789
```

WhatsApp can only be linked to one Gateway at a time — stop GCP before restarting laptop Gateway.
