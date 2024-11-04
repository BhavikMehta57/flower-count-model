import os
from fastapi import FastAPI, BackgroundTasks, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, TIMESTAMP, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from passlib.context import CryptContext
from datetime import datetime, timedelta
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from typing import List, Dict, Any
from transformers import DetrImageProcessor, DetrForObjectDetection
from PIL import Image
import torch

# Database Setup
DATABASE_URL = "mysql+pymysql://root:bhavik@localhost/flower_model_db"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# JWT Settings
SECRET_KEY = "FLOWER_COUNT_MODEL_APP_SECRET_KEY"  # Replace with a strong secret key
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 180

# Password Hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

app = FastAPI()

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Adjust this to allow your frontend origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# OAuth2 for JWT
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# User Model
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True)
    password_hash = Column(String(255))
    token = Column(String(255))
    created_at = Column(TIMESTAMP, default=datetime.utcnow)
    application = Column(String(255), default="web")
    disabled = Column(Boolean, default=False)

Base.metadata.create_all(bind=engine)

# User Model for Register and Login
class UserCreate(BaseModel):
    username: str
    password: str

# Helper Functions
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_password_hash(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# Dependency
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise credentials_exception
    return user

# Routes
@app.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    user_exists = db.query(User).filter(User.username == user.username).first()
    if user_exists:
        raise HTTPException(status_code=400, detail="Username already registered")
    hashed_password = get_password_hash(user.password)
    db_user = User(username=user.username, password_hash=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return {"message": "User registered successfully"}

@app.post("/token")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Incorrect username or password")
    access_token = create_access_token(data={"sub": user.username})
    user.token = access_token
    db.commit()
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me")
def read_users_me(current_user: User = Depends(get_current_user)):
    return {"username": current_user.username, "id": current_user.id}

# Initialize the image processor and model for object detection
image_processor = DetrImageProcessor.from_pretrained("smutuvi/flower_count_model")
model = DetrForObjectDetection.from_pretrained("smutuvi/flower_count_model")

# Define data models
class FlowerCountResponse(BaseModel):
    image: str
    image_name: str
    count: int

class TaskStatus(BaseModel):
    status: str
    images_processed: int
    total_images: int
    result: List[FlowerCountResponse] = []

task_results: Dict[str, List[FlowerCountResponse]] = {}
task_status: Dict[str, Dict[str, Any]] = {}

# Path to your local dataset
dataset_dir = "E:/Artemis/Artemis_Assignment/Backend/flower_count_test_data/test"

app.mount("/images", StaticFiles(directory=dataset_dir), name="images")

# Function to process images in the background
def process_images_task(task_id: str):
    # Initialize results as a list
    results = []
    
    # List all image files in the dataset directory
    image_files = [f for f in os.listdir(dataset_dir) if f.endswith(('.png', '.jpg', '.jpeg'))]

    for image_file in image_files:
        image_path = os.path.join(dataset_dir, image_file)
        
        # Load and process the image
        image = Image.open(image_path)
        encoding = image_processor(image, return_tensors="pt")  # Prepare image for the model

        # Run model prediction
        outputs = model(**encoding)

        # Filter outputs (keep only predictions with score > 0.5)
        target_sizes = torch.tensor([image.size[::-1]])  # height, width
        processed_results = image_processor.post_process_object_detection(outputs, target_sizes=target_sizes, threshold=0.5)[0]

        # Count the number of flowers detected (assuming 'flower' class is index 1)
        flower_count = sum(1 for i in range(len(processed_results['scores'])) if processed_results['scores'][i] > 0.5 and processed_results['labels'][i] == 1)

        # Append the result as a dictionary
        results.append({"image": f"http://localhost:8000/images/{image_file}", "image_name": image_file, "count": flower_count})
        task_results[task_id] = results

    # Store the results for the task
    task_results[task_id] = results
    task_status[task_id] = {
        "status": "Completed",
        "images_processed": len(results),
        "total_images": len(results)
    }

@app.post("/process-images/")
async def process_images_endpoint(background_tasks: BackgroundTasks, current_user: User = Depends(get_current_user)):
    task_id = f"task_{len(task_results) + 1}"
    image_files = [f for f in os.listdir(dataset_dir) if f.endswith(('.png', '.jpg', '.jpeg'))]
    task_status[task_id] = {
        "status": "Processing",
        "images_processed": 0,
        "total_images": len(image_files)
    }
    
    background_tasks.add_task(process_images_task, task_id)
    
    return {"task_id": task_id}

@app.get("/result/{task_id}", response_model=TaskStatus)
async def get_result(task_id: str, current_user: User = Depends(get_current_user)):
    status = task_status.get(task_id)

    if status is None:
        # Return a response indicating the task was not found
        return TaskStatus(status="Task not found", images_processed=0, total_images=0, result=[])

    results = task_results.get(task_id, [])
    images_processed = len(results)
    
    return TaskStatus(status=status["status"], images_processed=images_processed, total_images=status["total_images"], result=results)
