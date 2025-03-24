from pydantic import BaseModel



class ChatDTO(BaseModel):
    user_prompt : str
