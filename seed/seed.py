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

def create_subscription_plans():
    plans = [
        ("Free", "Basic free tier for individuals", 0.00, False),
        ("Starter", "Small business starter plan", 29.00, False),
        ("Professional", "Full-featured plan for growing businesses", 79.00, False),
        ("Student", "Free plan for verified students at eligible institutions", 0.00, True),
    ]
    plan_ids = {}
    for name, description, price, is_student in plans:
        cur.execute(
            """
            INSERT INTO subscription_plans (name, description, price_monthly, is_student_plan)
            VALUES (%s, %s, %s, %s) RETURNING id
            """,
            (name, description, price, is_student)
        )
        plan_ids[name] = cur.fetchone()[0]
    return plan_ids

def create_eligible_institutions(plan_ids):
    student_plan_id = plan_ids["Student"]
    institutions = [
        ("42 Heilbronn", "Germany", student_plan_id),
        ("42 Berlin", "Germany", student_plan_id),
        ("42 Wolfsburg", "Germany", student_plan_id),
        ("42 Paris", "France", student_plan_id),
        ("42 Barcelona", "Spain", student_plan_id),
    ]
    institution_ids = {}
    for name, country, plan_id in institutions:
        cur.execute(
            """
            INSERT INTO eligible_institutions (name, country, plan_id)
            VALUES (%s, %s, %s) RETURNING id
            """,
            (name, country, plan_id)
        )
        institution_ids[name] = cur.fetchone()[0]
    return institution_ids

def create_company(plan_ids):
    cur.execute(
        "INSERT INTO companies (name, industry, country, plan_id) VALUES (%s,%s,%s,%s) RETURNING id",
        ("keepITlocal.ai", "AI Automation Agency", "Germany", plan_ids["Professional"])
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

plan_ids = create_subscription_plans()
create_eligible_institutions(plan_ids)
company_id = create_company(plan_ids)
create_users(company_id)
create_clients()
create_vendors()
create_invoices()
create_tickets()

conn.commit()
cur.close()
conn.close()

print("Seed data created.")