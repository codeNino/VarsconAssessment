from fastapi import (FastAPI)
from fastapi.responses import JSONResponse
import uvicorn
from factory import GitAssistant
from dto import ChatDTO


app = FastAPI(title="Varscon Git Assistant Microservice",)



@app.post("/api/chatbot")
async def prompt_assistant(request: ChatDTO):
    try:
        response = GitAssistant.chat(request.user_prompt)
        return JSONResponse(response, 200)
    except Exception as e:
        print("Failed to get response from bot ::%s ", e)
        return JSONResponse("Internal Server Error", 500)


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0",port=8000, reload=True)