import smtplib
from email.message import EmailMessage
from jinja2 import Environment, FileSystemLoader
from pathlib import Path
import os

TEMPLATES_DIR = Path(__file__).resolve().parent / "templates"

def send_email_smtp(to_email: str, subject: str, template_name: str, context: dict, smtp_url=None):
    smtp_host = os.environ.get("SMTP_HOST", "localhost")
    smtp_port = int(os.environ.get("SMTP_PORT", "25"))
    from_email = os.environ.get("SMTP_FROM", "no-reply@creatorinsights.local")

    env = Environment(loader=FileSystemLoader(str(TEMPLATES_DIR)))
    template = env.get_template(template_name)
    html = template.render(**context)

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = from_email
    msg["To"] = to_email
    msg.set_content(html, subtype="html")

    with smtplib.SMTP(smtp_host, smtp_port) as s:
        s.send_message(msg)
