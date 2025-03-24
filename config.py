from dotenv import load_dotenv
import os

load_dotenv()


class Config:

    OPENAI_KEY= os.environ.get("OPENAI_KEY")
    COMPOSIO_KEY= os.environ.get("COMPOSIO_KEY")
    COMPOSIO_INTEGRATION_ID = os.environ.get("COMPOSIO_INTEGRATION_ID")