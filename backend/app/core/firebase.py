import firebase_admin
from firebase_admin import credentials, auth
from app.core.config import settings


def init_firebase():
    if firebase_admin._apps:
        return firebase_admin.get_app()

    # Try JSON credentials first (for production on Render)
    firebase_creds = settings.get_firebase_credentials()
    if firebase_creds:
        cred = credentials.Certificate(firebase_creds)
        return firebase_admin.initialize_app(cred)

    # Then try file path (for local development)
    if settings.firebase_credentials_path:
        cred = credentials.Certificate(settings.firebase_credentials_path)
        return firebase_admin.initialize_app(cred)

    # Initialize with default application credentials if available
    return firebase_admin.initialize_app()


# Initialize at import time
init_firebase()
