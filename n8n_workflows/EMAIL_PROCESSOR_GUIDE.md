# Email Processor with AI - Setup Guide

## Overview
Automated email classification system using Mistral 7B local AI to extract structured information from emails and store in PostgreSQL database.

## Features
- ✅ AI-powered email classification (info, order, request, invoice, support_request, other)
- ✅ Automatic extraction: sender name, topic, summary, dates, costs, phone numbers
- ✅ Priority assessment (low, medium, high)
- ✅ Action required detection
- ✅ PostgreSQL storage with indexed queries
- ✅ RESTful webhook API

---

## Setup Steps

### 1. Create Database Table

SSH into your server and run:

```bash
ssh deploy@localhost
cd ~/projects/Server

# Apply the email classifications schema
docker compose cp db/email_classifications.sql db:/tmp/
docker compose exec db psql -U ${POSTGRES_USER} -d mydb -f /tmp/email_classifications.sql
```

Verify table creation:
```bash
docker compose exec db psql -U ${POSTGRES_USER} -d mydb -c "\d email_classifications"
```

### 2. Configure PostgreSQL Credentials in n8n

1. **Access n8n** via SSH tunnel:
   ```bash
   ssh -L 5678:localhost:5678 -L 8087:localhost:8087 -L 8088:localhost:8088 deploy@localhost
   ```
   
2. **Open n8n:** http://localhost:5678
   - Username: `admin`
   - Password: `<N8N_PASSWORD>`

3. **Add PostgreSQL Credential:**
   - Click your profile (bottom left) → Settings → Credentials
   - Click "Add Credential" → Search "PostgreSQL"
   - Fill in:
     - **Name:** `PostgreSQL account`
     - **Host:** `db`
     - **Database:** `mydb`
     - **User:** `${POSTGRES_USER}`
     - **Password:** `<POSTGRES_PASSWORD>`
     - **Port:** `5432`
   - Test Connection → Save

### 3. Import Workflow

1. In n8n, click **Workflows** (top left)
2. Click **Add workflow** → **Import from File**
3. Upload: `/home/mana/projects/Server/n8n_workflows/email_processor_ai.json`
4. The workflow will open automatically
5. Click **Save** (top right)
6. Click **Activate** toggle (top right) to enable the webhook

### 4. Get Webhook URL

1. In the workflow, click the **"Email Webhook"** node
2. Copy the **Production URL** (looks like: `https://your-server/webhook/process-email` or `http://localhost:5678/webhook-test/process-email`)
3. For testing via tunnel, use the **Test URL**

---

## Usage

### Test via cURL (Local - via SSH tunnel)

```bash
curl -X POST http://localhost:5678/webhook-test/email-processor \
  -H "Content-Type: application/json" \
  -d '{
    "sender_email": "john.doe@example.com",
    "email_content": "Hi, I wanted to follow up on invoice #12345 for €250 that was due on November 20th. Please process payment urgently. You can reach me at +49 123 456789. Thanks, John Doe"
  }'
```

### Expected Response

```json
{
  "status": "success",
  "message": "Email processed and classified",
  "data": {
    "id": 1,
    "sender_name": "John Doe",
    "email_type": "invoice",
    "topic": "Invoice payment follow-up",
    "summary": "Follow-up on invoice #12345 for €250 due November 20th. Urgent payment request.",
    "priority": "high",
    "action_required": "yes"
  }
}
```

---

## Email Format

### Required Fields
```json
{
  "email_content": "The full email text"
}
```

### Optional Fields
```json
{
  "sender_email": "email@example.com",
  "email_content": "Full email body..."
}
```

---

## Database Queries

### View All Classifications
```sql
SELECT * FROM email_classifications ORDER BY received_at DESC LIMIT 10;
```

### High Priority Emails Requiring Action
```sql
SELECT * FROM high_priority_emails;
```

### Pending Invoices
```sql
SELECT * FROM pending_invoices;
```

### Count by Type
```sql
SELECT 
    email_type, 
    COUNT(*) as count,
    SUM(CASE WHEN action_required = 'yes' THEN 1 ELSE 0 END) as requires_action
FROM email_classifications
GROUP BY email_type
ORDER BY count DESC;
```

### Emails with Costs
```sql
SELECT 
    sender_name,
    topic,
    cost_amount,
    date_deadline,
    summary
FROM email_classifications
WHERE cost_amount IS NOT NULL
ORDER BY cost_amount DESC;
```

---

## Workflow Details

### Node Breakdown

1. **Email Webhook** - Receives POST requests with email data
2. **AI Classification** - Sends email to Mistral for analysis
3. **Parse AI Response** - Extracts JSON from AI response, handles errors
4. **Save to Database** - Inserts classified data into PostgreSQL
5. **Send Response** - Returns success message with extracted data

### AI Prompt Structure

The AI is prompted to extract:
- `sender_name` - Extracted name or "Unknown"
- `email_type` - Category (info, order, request, invoice, support_request, other)
- `topic` - Brief topic summary
- `summary` - 2-3 sentence summary
- `date_deadline` - Any dates or deadlines mentioned
- `cost_amount` - Monetary amounts
- `phone_number` - Contact numbers
- `priority` - Urgency level (low, medium, high)
- `action_required` - Whether action is needed (yes/no)
- `additional_info` - Other important details

---

## Integration Examples

### Connect to Email Server (IMAP)

Add an **Email Trigger (IMAP)** node before the AI Classification:

1. Add Node → Trigger → Email Trigger (IMAP)
2. Configure:
   - **Email:** your-email@example.com
   - **Password:** your-app-password
   - **Host:** imap.gmail.com (or your provider)
   - **Port:** 993
   - **SSL:** Yes
3. Map fields:
   ```
   sender_email: {{ $json.from.address }}
   email_content: {{ $json.text }}
   ```

### Webhook from External System

Configure your mail server or CRM to POST to:
```
https://your-server.com/webhook/process-email
```

Body:
```json
{
  "sender_email": "{{sender}}",
  "email_content": "{{body}}"
}
```

---

## Troubleshooting

### Workflow Not Triggering
- Check workflow is **Active** (toggle in top right)
- Verify webhook URL is correct
- Check n8n logs: `docker compose logs -f n8n`

### AI Response Parse Errors
- Check llama_wrapper logs: `docker compose logs -f llama_wrapper`
- Verify Ollama is running: `docker compose ps ollama`
- Test AI directly:
  ```bash
  curl -X POST http://localhost:8087/generate \
    -H "Content-Type: application/json" \
    -d '{"prompt":"Test","max_tokens":50,"model":"mistral:7b-instruct-q4_0"}'
  ```

### Database Connection Failed
- Verify PostgreSQL credentials in n8n
- Check database is running: `docker compose ps db`
- Test connection:
  ```bash
  docker compose exec db psql -U ${POSTGRES_USER} -d mydb -c "SELECT 1;"
  ```

### Slow AI Processing
- Mistral 7B processes ~8-15 tokens/second on CPU
- Average response time: 5-15 seconds per email
- Consider batching if processing many emails

---

## Enhancements

### Add More Fields
Edit the workflow "Parse AI Response" node to extract additional fields:
- Project names
- Contract numbers
- Urgency keywords
- Attachment counts

### Add Notifications
Add nodes after "Save to Database":
- **Send Email** - Notify team of high-priority items
- **Slack** - Post to channel for invoices
- **HTTP Request** - Trigger external systems

### Create Dashboard
Use **Metabase** (http://localhost:3000) to create visualizations:
- Email volume over time
- Distribution by type
- Average response priority
- Pending actions timeline

---

## Performance

- **Processing Time:** 5-15 seconds per email (AI classification)
- **Throughput:** ~4-10 emails/minute (single instance)
- **Model Size:** 4.1 GB (mistral:7b-instruct-q4_0)
- **Memory Usage:** ~6-8 GB during processing

---

## Security Notes

- Webhook is accessible via localhost only (SSH tunnel required)
- For production, add authentication to webhook
- Store sensitive emails encrypted at rest
- Consider data retention policies (GDPR compliance)

---

## Next Steps

1. ✅ Set up database table
2. ✅ Configure PostgreSQL in n8n
3. ✅ Import workflow
4. ✅ Test with sample email
5. Connect to real email source (IMAP/webhook)
6. Create Metabase dashboard
7. Set up notifications for high-priority emails

---

**Created:** November 15, 2025  
**Compatible with:** n8n latest, PostgreSQL 16, Ollama/Mistral 7B
