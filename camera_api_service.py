# camera_api_service.py
# FastAPI service to expose CSI camera using Vilib

import time

from fastapi import FastAPI
from fastapi.responses import FileResponse
from vilib import Vilib

app = FastAPI()


# Start the camera when the service starts
@app.on_event("startup")
async def startup_event():
    Vilib.camera_start(vflip=False, hflip=False)

    # Start the Vilib display
    # <img src="http://<ROBOT_IP>:9000/mjpg" alt="Camera Stream" />
    Vilib.display(local=True, web=True)


@app.get("/capture", response_class=FileResponse)
def capture_image():
    timestamp = time.strftime("%y-%m-%d_%H-%M-%S", time.localtime())
    Vilib.take_photo(timestamp, "/tmp")
    image_path = f"/tmp/{timestamp}.jpg"
    return FileResponse(image_path, media_type="image/jpeg")


@app.get("/")
def root():
    return {"status": "Camera API running"}
