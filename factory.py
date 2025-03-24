from langchain_openai import ChatOpenAI
from composio_langgraph import Action, ComposioToolSet
from config import Config
from workflow import VarsconAgent


gpt_model = ChatOpenAI(
    model="gpt-4o",
    temperature=0.7,
    max_tokens=None,
    timeout=None,
    max_retries=2,
    api_key=Config.OPENAI_KEY
)

toolset = ComposioToolSet(Config.COMPOSIO_KEY)


tools = toolset.get_tools(
    actions=[
        Action.GITHUB_GET_THE_AUTHENTICATED_USER,
        Action.GITHUB_CREATE_A_REPOSITORY_FOR_THE_AUTHENTICATED_USER
    ]
)


GitAssistant = VarsconAgent(gpt_model, tools)

