import psycopg2
from faker import Faker
import random
import os

fake = Faker("de_DE")

conn = psycopg2.connect(
    host="localhost",
    database=os.getenv("POSTGRES_DB", "mydb"),
    user=os.getenv("POSTGRES_USER", "admin"),
    password=os.getenv("POSTGRES_PASSWORD", "secret")
)

cur = conn.cursor()

def create_company():
    cur.execute(
        "INSERT INTO companies (name, industry, country) VALUES (%s,%s,%s) RETURNING id",
        ("keepITlocal.ai", "AI Automation Agency", "Germany")
    )
    return cur.fetchone()[0]

def create_users(company_id):

    users = [
        ("Matthias Naumann","admin"),
        ("Anna Weber","sales"),
        ("Lukas Fischer","support"),
        ("Sophie Keller","accounting"),
        ("Jonas Braun","technician")
    ]

    for name, role in users:
        cur.execute(
            "INSERT INTO users (company_id,name,email,role) VALUES (%s,%s,%s,%s)",
            (company_id,name,fake.email(),role)
        )

def create_clients(n=10):

    industries = [
        "Handwerk",
        "Restaurant",
        "Consulting",
        "Healthcare",
        "Retail",
        "Manufacturing",
        "E-commerce"
    ]

    for _ in range(n):

        cur.execute(
            """
            INSERT INTO clients (name,industry,size,email,payment_terms,risk_score)
            VALUES (%s,%s,%s,%s,%s,%s)
            """,
            (
                fake.company(),
                random.choice(industries),
                random.choice(["small","medium"]),
                fake.company_email(),
                random.choice([14,30]),
                random.randint(1,10)
            )
        )

def create_vendors():

    vendors = [
        ("Hetzner Cloud","Hosting"),
        ("Ionos","Domains"),
        ("Freelance Dev GmbH","Contractor"),
        ("Adobe","Software"),
        ("Local Marketing Studio","Marketing")
    ]

    for name,service in vendors:
        cur.execute(
            "INSERT INTO vendors (name,service_type,email) VALUES (%s,%s,%s)",
            (name,service,fake.company_email())
        )

def create_invoices():

    cur.execute("SELECT id FROM clients")
    clients = [c[0] for c in cur.fetchall()]

    for _ in range(40):

        client=random.choice(clients)

        amount=random.randint(200,5000)

        status=random.choice(["paid","open","overdue"])

        cur.execute(
            """
            INSERT INTO invoices (client_id,amount,status,issued_date,due_date)
            VALUES (%s,%s,%s,NOW(),NOW()+INTERVAL '30 days')
            """,
            (client,amount,status)
        )

def create_tickets():

    cur.execute("SELECT id FROM clients")
    clients = [c[0] for c in cur.fetchall()]

    subjects=[
        "Website down",
        "Need new landing page",
        "Invoice question",
        "AI chatbot configuration",
        "SEO help"
    ]

    for _ in range(25):

        cur.execute(
            """
            INSERT INTO tickets (client_id,subject,priority,status)
            VALUES (%s,%s,%s,%s)
            """,
            (
                random.choice(clients),
                random.choice(subjects),
                random.choice(["low","medium","high"]),
                random.choice(["open","closed","waiting"])
            )
        )

company_id=create_company()
create_users(company_id)
create_clients()
create_vendors()
create_invoices()
create_tickets()

conn.commit()
cur.close()
conn.close()

print("Seed data created.")