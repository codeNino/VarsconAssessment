from typing import Literal, Sequence
from langgraph.graph import MessagesState, StateGraph
from langgraph.prebuilt import ToolNode
from langchain_core.tools import StructuredTool
from langchain_core.messages import HumanMessage
from langchain_core.language_models.chat_models import BaseChatModel



class VarsconAgent:

    def __init__(self, llm: BaseChatModel, 
        tools: Sequence[StructuredTool]):
       
        self.__tool_node = ToolNode(tools)
        self.__model_with_tools = llm.bind_tools(tools)

        workflow = StateGraph(MessagesState)

        workflow.add_node("agent", self.__call_model)
        workflow.add_node("tools", self.__tool_node)
        workflow.add_edge("__start__", "agent")
        workflow.add_conditional_edges(
    "agent",
    self.__should_continue,
)
        workflow.add_edge("tools", "agent")

        self.__app = workflow.compile()


    def __call_model(self, state: MessagesState):
        """
        Process messages through the LLM and return the response
        """
        messages = state["messages"]
        response = self.__model_with_tools.invoke(messages)
        return {"messages": [response]}



    def __should_continue(self, state: MessagesState) -> Literal["tools", "__end__"]:
        """
        Determine if the conversation should continue to tools or end
        Returns:
        - "tools" if the last message contains tool calls
        - "__end__" otherwise
        """
        messages = state["messages"]
        last_message = messages[-1]
        if last_message.tool_calls:
            return "tools"
        return "__end__"

    def chat(self, user_input: str) -> str:
        updatedState = self.__app.invoke({"messages": [HumanMessage(content=user_input)]})
        return updatedState.get("messages")[-1].content

