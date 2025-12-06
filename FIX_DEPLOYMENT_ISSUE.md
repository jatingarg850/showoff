# Fix: Deployment Issue - Wrong Repository Structure

## Problem

You cloned the entire `showoff` repository, but the `server` folder is inside it. The structure is:

```
showoff/
├── apps/
├── server/          ← This is what we need
├── services/
└── ...
```

But npm is looking for `package.json` in the root.

---

## Solution

### Option 1: Use the Correct Path (Easiest)

Navigate to the server folder:

```bash
cd /home/cloudshell-user/showoff-server/server
npm install
```

---

### Option 2: Copy Server Folder

```bash
cp -r /home/cloudshell-user/showoff-server/server /home/ec2-user/showoff-api
cd /home/ec2-user/showoff-api
npm install
```

---

### Option 3: Start Fresh (Recommended)

Delete and re-clone just the server:

```bash
rm -rf /home/cloudshell-user/showoff-server

# Clone just the server folder
git clone --depth 1 --filter=blob:none --sparse https://github.com/jatingarg850/showoff.git
cd showoff
git sparse-checkout set server
cd server
npm install
```

---

## Quick Fix (Do This Now)

If you're in CloudShell, run:

```bash
cd /home/cloudshell-user/showoff-server/server
npm install
```

Then continue with the rest of the setup.

---

## For EC2 SSH Connection

If you want to do this on EC2 instead:

```bash
ssh -i C:\Users\coddy\showoff-key.pem ec2-user@3.110.103.187

# Once connected:
cd /home/ec2-user
git clone https://github.com/jatingarg850/showoff.git
cd showoff/server
npm install
pm2 start server.js --name "showoff-api"
```

---

## Next Steps

1. Navigate to the correct `server` folder
2. Run `npm install`
3. Create `.env` file
4. Start server with PM2
5. Configure Nginx
6. Test

---

## Commands to Run Now

```bash
# Navigate to server folder
cd /home/cloudshell-user/showoff-server/server

# Install dependencies
npm install

# Create .env file
nano .env
```

Paste your environment variables and save.

```bash
# Start server
pm2 start server.js --name "showoff-api"
pm2 save
sudo pm2 startup
pm2 logs showoff-api
```

---

## Verify

```bash
curl http://3.110.103.187:3000/api/health
```

Should return: `{"status": "ok"}`
