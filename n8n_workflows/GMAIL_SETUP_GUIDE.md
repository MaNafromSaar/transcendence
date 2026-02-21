# Gmail Email Processor Setup Guide

## Quick Setup Steps

### 1️⃣ Create Gmail App Password

Since you're using Gmail, you need an **App Password** (not your regular Gmail password).

**Steps:**
1. Go to your Google Account: https://myaccount.google.com/
2. Select **Security** (left sidebar)
3. Enable **2-Step Verification** if not already enabled
   - Click "2-Step Verification" → Follow prompts
4. Once 2FA is enabled, go back to **Security**
5. Scroll down to **App passwords** (under "2-Step Verification")
6. Click **App passwords**
7. In "Select app" dropdown: choose **Mail**
8. In "Select device" dropdown: choose **Other** → type `n8n`
9. Click **Generate**
10. **Copy the 16-character password** (format: `xxxx xxxx xxxx xxxx`)
    - ⚠️ You won't see this again! Save it somewhere safe temporarily

---

### 2️⃣ Create Database Table

```bash
# SSH into server
ssh deploy@localhost

# Apply email classifications schema
cd ~/projects/Server
docker compose cp db/email_classifications.sql db:/tmp/
docker compose exec db psql -U ${POSTGRES_USER} -d mydb -f /tmp/email_classifications.sql
```

Verify:
```bash
docker compose exec db psql -U ${POSTGRES_USER} -d mydb -c "\d email_classifications"
```

---

### 3️⃣ Configure n8n

**A. Establish SSH Tunnel:**
```bash
ssh -L 5678:localhost:5678 -L 8088:localhost:8088 deploy@localhost
```

**B. Open n8n:** http://localhost:5678
- Username: `admin`
- Password: `<N8N_PASSWORD>`

**C. Add PostgreSQL Credential:**
1. Click your profile icon (bottom left) → **Settings** → **Credentials**
2. Click **"Add Credential"**
3. Search and select **"PostgreSQL"**
4. Fill in:
   - **Name:** `PostgreSQL account`
   - **Host:** `db`
   - **Database:** `mydb`
   - **User:** `${POSTGRES_USER}`
   - **Password:** `<POSTGRES_PASSWORD>`
   - **Port:** `5432`
   - **SSL:** Off
5. Click **"Test"** → Should show ✅ "Connection tested successfully"
6. Click **"Save"**

**D. Add Gmail IMAP Credential:**
1. Still in **Credentials**, click **"Add Credential"**
2. Search and select **"IMAP"**
3. Fill in:
   - **Name:** `Gmail IMAP`
   - **User:** `your-email@gmail.com` (your full Gmail address)
   - **Password:** `xxxx xxxx xxxx xxxx` (the 16-char App Password from step 1)
   - **Host:** `imap.gmail.com`
   - **Port:** `993`
   - **SSL/TLS:** ✅ Enabled
4. Click **"Save"** (no test button, will test during workflow execution)

---

### 4️⃣ Import Gmail Workflow

1. Go to **Workflows** (left sidebar)
2. Click **"Add workflow"** dropdown → **"Import from File"**
3. Upload: `/home/mana/projects/Server/n8n_workflows/gmail_email_processor_ai.json`
4. The workflow opens automatically showing these nodes:
   - 📧 Gmail Trigger
   - 📝 Extract Email Data
   - 🤖 AI Classification
   - 🧹 Parse AI Response
   - 💾 Save to Database
   - ⚠️ High Priority?
   - 📢 Log High Priority
5. Click each node and verify credentials are linked:
   - **Gmail Trigger** → Should show "Gmail IMAP" credential
   - **Save to Database** → Should show "PostgreSQL account" credential
6. Click **"Save"** (top right)
7. Click **"Activate"** toggle (top right) → Should turn green

---

### 5️⃣ Test the Workflow

**Option A: Send Test Email to Your Gmail**

1. From another email address (or same Gmail), send a test email:
   ```
   To: your-email@gmail.com
   Subject: Invoice Follow-up #12345
   Body:
   Hi,
   
   I wanted to follow up on invoice #12345 for €250 that was 
   due on November 20th. Please process payment urgently.
   
   You can reach me at +49 123 456789.
   
   Thanks,
   John Doe
   ```

2. Wait 1-2 minutes (n8n polls Gmail every minute)

3. In n8n, click **"Executions"** (left sidebar)
   - You should see a new execution appear
   - Click it to see the flow through each node
   - Check if data was extracted correctly

4. Verify database:
   ```bash
   docker compose exec db psql -U ${POSTGRES_USER} -d mydb -c "SELECT id, sender_name, email_type, topic, priority FROM email_classifications ORDER BY id DESC LIMIT 5;"
   ```

**Option B: Manual Test (Execute Workflow)**

1. In the workflow, click **"Test workflow"** (top right)
2. Click the **"Gmail Trigger"** node
3. Click **"Fetch Test Event"** (right panel)
4. n8n will check your Gmail and pull the most recent unread email
5. Watch the data flow through each node
6. Check database as above

---

## What Happens Now?

Once activated, n8n will:
1. **Check Gmail every 1 minute** for new unread emails
2. **Extract** email content, sender, subject
3. **Send to Mistral AI** for classification
4. **Parse** the AI response into structured data
5. **Save** to PostgreSQL database
6. **Mark email as read** in Gmail
7. **Log** high-priority items (you can add Slack/email notifications here)

---

## Monitoring

### View Executions
- In n8n: **Executions** (left sidebar) shows all runs
- Click any execution to see detailed flow and data

### Check Database
```bash
# Recent emails
docker compose exec db psql -U ${POSTGRES_USER} -d mydb -c "SELECT * FROM email_classifications ORDER BY received_at DESC LIMIT 10;"

# High priority emails
docker compose exec db psql -U ${POSTGRES_USER} -d mydb -c "SELECT * FROM high_priority_emails;"

# Count by type
docker compose exec db psql -U ${POSTGRES_USER} -d mydb -c "SELECT email_type, COUNT(*) FROM email_classifications GROUP BY email_type;"
```

### View Logs
```bash
# n8n logs
docker compose logs -f n8n

# AI wrapper logs
docker compose logs -f llama_wrapper

# Ollama logs
docker compose logs -f ollama
```

---

## Troubleshooting

### "Credentials not found"
- Re-add credentials in n8n Settings → Credentials
- Make sure names match exactly: `Gmail IMAP` and `PostgreSQL account`

### "Authentication failed" (Gmail)
- Double-check App Password (16 characters, no spaces when entering)
- Verify 2FA is enabled on Google Account
- Try generating a new App Password

### "Connection refused" (PostgreSQL)
- Verify database is running: `docker compose ps db`
- Check credentials match .env file
- Test connection: `docker compose exec db psql -U ${POSTGRES_USER} -d mydb -c "SELECT 1;"`

### No emails being processed
- Check workflow is **Active** (green toggle)
- Send a test email and wait 1-2 minutes
- Click **"Executions"** to see if anything ran
- Check Gmail Trigger settings: Poll interval should be "Every Minute"

### AI classification slow
- Normal: 5-15 seconds per email
- Check: `curl http://localhost:8087/health` (should show Ollama backend)
- Monitor: `docker stats ollama` (should show CPU activity during processing)

---

## Customization

### Change Poll Frequency
1. Click **"Gmail Trigger"** node
2. Under **"Trigger On"** → adjust poll interval (default: Every Minute)
3. Options: Every 5 minutes, 10 minutes, etc.

### Add Email Filters
1. Click **"Gmail Trigger"** node
2. Add **"Options"** → **"Custom Email Config"**
3. Use IMAP search criteria:
   - `UNSEEN SUBJECT "invoice"` - Only invoices
   - `UNSEEN FROM "example.com"` - Only from specific domain
   - `UNSEEN SINCE "15-Nov-2025"` - Since specific date

### Add Notifications
After "High Priority?" node:
1. Add **"Send Email"** node → notify your team
2. Add **"Slack"** node → post to channel
3. Add **"HTTP Request"** node → webhook to external system

### Adjust AI Prompt
1. Click **"AI Classification"** node
2. Edit the `prompt` parameter to add/remove fields
3. Adjust categories in `email_type` list
4. Add custom extraction fields

---

## Performance

- **Polling:** Gmail checked every 60 seconds
- **Processing:** ~5-15 seconds per email (Mistral AI)
- **Throughput:** ~4-6 emails/minute (sequential processing)
- **Memory:** ~6-8 GB during AI processing

---

## Security & Privacy

✅ **What's Secure:**
- App Password (not your real Gmail password)
- n8n only accessible via SSH tunnel (localhost)
- Database credentials in .env (not in version control)
- Emails marked as "read" after processing (no deletion)

⚠️ **Considerations:**
- Original emails stored in database (consider encryption)
- Gmail App Password has full mailbox access (read-only in this workflow)
- For production: add authentication to n8n, use HTTPS

---

## Next Steps

1. ✅ Set up Gmail App Password
2. ✅ Create database table
3. ✅ Add credentials to n8n
4. ✅ Import and activate workflow
5. ✅ Send test email
6. Add Slack/Email notifications for high-priority items
7. Create Metabase dashboard for analytics
8. Set up automated database backups

---

**Your Gmail will now be automatically processed by local AI! 🎉**

Questions or issues? Check:
- n8n Executions tab for workflow runs
- `docker compose logs -f n8n llama_wrapper ollama` for detailed logs
- Database: `SELECT * FROM email_classifications;`
