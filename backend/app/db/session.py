from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings


# Get the correct database URL (handles postgres:// -> postgresql://)
database_url = settings.actual_database_url

# SQLite-specific settings
connect_args = {}
if database_url.startswith("sqlite"):
    connect_args = {"check_same_thread": False}

# Create engine with appropriate settings
engine = create_engine(
    database_url, 
    connect_args=connect_args,
    pool_pre_ping=True,  # Enable connection health checks
    pool_recycle=300,    # Recycle connections every 5 minutes
)

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
