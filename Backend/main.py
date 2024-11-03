import os
from fastapi import FastAPI, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Dict, Any
from transformers import DetrImageProcessor, DetrForObjectDetection
from PIL import Image
import torch

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Adjust this to allow your frontend origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
async def process_images_endpoint(background_tasks: BackgroundTasks):
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
async def get_result(task_id: str):
    status = task_status.get(task_id)

    if status is None:
        # Return a response indicating the task was not found
        return TaskStatus(status="Task not found", images_processed=0, total_images=0, result=[])

    results = task_results.get(task_id, [])
    images_processed = len(results)
    
    return TaskStatus(status=status["status"], images_processed=images_processed, total_images=status["total_images"] , result=results)
