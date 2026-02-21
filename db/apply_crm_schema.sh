#!/bin/bash
# ============================================================================
# CRM Schema Migration Script
# ============================================================================
# Apply CRM database schema to existing PostgreSQL instance
# Usage: ./apply_crm_schema.sh
# ============================================================================

set -e  # Exit on error

# Configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-mydb}"
DB_USER="${DB_USER:-${POSTGRES_USER}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================================"
echo "keepITlocal CRM Schema Migration"
echo "================================================"
echo ""
echo "Database: $DB_NAME"
echo "Host: $DB_HOST:$DB_PORT"
echo "User: $DB_USER"
echo ""

# Check if running locally or via SSH
if [ "$DB_HOST" = "localhost" ]; then
    echo "⚠️  Warning: This will apply schema to LOCAL PostgreSQL"
    echo "For server deployment, use: ssh deploy@localhost and run there"
else
    echo "Connecting to remote database: $DB_HOST"
fi

echo ""
read -p "Continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "🔧 Applying CRM schema..."
echo ""

# Apply schema via Docker (if using docker-compose setup)
if command -v docker &> /dev/null && docker ps | grep -q "postgres"; then
    echo "Using Docker PostgreSQL container..."
    docker exec -i $(docker ps -q -f name=db) psql -U $DB_USER -d $DB_NAME < "$SCRIPT_DIR/crm_schema.sql"
else
    # Direct psql connection
    echo "Using direct psql connection..."
    PGPASSWORD="${DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SCRIPT_DIR/crm_schema.sql"
fi

echo ""
echo "✅ Schema applied successfully!"
echo ""
echo "📊 Created tables:"
echo "  - kunden (customers)"
echo "  - produkte (products/services)"
echo "  - projekte (projects)"
echo "  - interaktionen (interactions)"
echo "  - angebote (quotes)"
echo "  - angebote_positionen (quote line items)"
echo "  - rechnungen (invoices)"
echo "  - aufgaben (tasks)"
echo ""
echo "📈 Created views:"
echo "  - v_kunden_overview"
echo "  - v_projekt_pipeline"
echo "  - v_umsatz_overview"
echo "  - v_aufgaben_dashboard"
echo "  - v_sales_funnel"
echo ""
echo "🎯 Next steps:"
echo "  1. Access Metabase: http://localhost:3000"
echo "  2. Setup dashboards using METABASE_DASHBOARDS.md"
echo "  3. Create HTML forms using crm_forms/ templates"
echo "  4. Setup n8n automation for email → CRM integration"
echo ""
