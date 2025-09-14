import argparse
from pathlib import Path
from langchain_openai import OpenAIEmbeddings
from langchain_openai import ChatOpenAI
from qdrant_client import QdrantClient, models

from langchain.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain.globals import set_debug

#def read_pipeline(): 


def main():
    parser = argparse.ArgumentParser(description="Load text files into documents list")
    parser.add_argument("pipeline", type=Path, help="Pipeline to translate")
    args = parser.parse_args()

    pipeline_content = ""
    try:
        with open(args.pipeline, "r") as f:
            pipeline_content = f.read()
    except FileNotFoundError:
        print(f"Error: File '{args.pipeline}' not found.")
    except Exception as e:
        print(f"Error: {e}")
    

    set_debug(True)
    qdrant_client = QdrantClient(host="80.188.223.202", port=10401)
      
    embeddings = OpenAIEmbeddings(
        base_url="http://80.188.223.202:10433/openai/v1",
        model="qwen3",
        api_key="aaa"
        )


    print(pipeline_content)
    pipelineContextPrompt = f"Jenkins pipeline is: {pipeline_content.strip()} translate it to GitHub Action workflow using reusable actions"


    results = qdrant_client.query_points(
        collection_name="github_actions_version",
        query= embeddings.embed_query("Github action for: {pipelineContextPrompt}"),
        limit=3
    )
    print([{ "payload": p.payload, "score": p.score} for p in results.points])
    context = "\n######################".join([p.payload['content'].strip() for p in results.points])


    #Prompt catalogue https://smith.langchain.com/hub/langchain-ai/retrieval-qa-chat
    prompt_template = """SYSTEM: You are an expert GitHub CI/CD engineer. 
    I will provide you with a Jenkinsfile that defines a CI/CD pipeline. 

    USER:
    {pipelineContextPrompt} from context: {context}
    
    Requirements:
    Workflow must call actions from context.
    Jobs of workflow should not repeat steps that are part of composite actions already used. 
    Use latest versions of standard actions.
    Workflow and actions will be a part the same repository and use standard github actions directories.
    """
    
    prompt = PromptTemplate.from_template(
        prompt_template)

    # translator_model = ChatOpenAI(
    #     base_url="http://80.188.223.202:10434/openai/v1",
    #     model="deepseek",
    #     api_key="aaa",
    #     temperature=0
    # )

    translator_model = ChatOpenAI(
        base_url="http://80.188.223.202:10434/v1",
        model="/mnt/models/gptoss",
        api_key="aaa",
        temperature=0.2
    )

    github_actions_chain = prompt | translator_model | StrOutputParser()
    response = github_actions_chain.invoke({"pipelineContextPrompt": pipelineContextPrompt, "context": context})
    print(response)
    

if __name__ == "__main__":
    main()

