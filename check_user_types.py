import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Use the application default credentials
cred = credentials.Certificate('serviceAccountKey.json')
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

db = firestore.client()

users_ref = db.collection('users')
docs = users_ref.stream()

user_types = set()
for doc in docs:
    data = doc.to_dict()
    utype = data.get('userType')
    user_types.add(str(utype))
    if utype in ['UserType.driver', 'driver', 'Driver']:
        print(f"Found driver: {doc.id} -> {utype}")
    if utype in ['UserType.serviceProvider', 'serviceProvider', 'ServiceProvider']:
        print(f"Found service provider: {doc.id} -> {utype}")

print(f"Distinct user types found: {user_types}")
