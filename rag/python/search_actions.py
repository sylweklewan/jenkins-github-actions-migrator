import argparse
import re
from pathlib import Path
from langchain_openai import OpenAIEmbeddings
from langchain_openai import ChatOpenAI
from qdrant_client import QdrantClient, models

from langchain.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnableLambda
#from langchain.globals import set_debug


def extract_yaml_as_string(rsp):
    """
    Extract all YAML code blocks (```yaml ... ```) from text
    and return them concatenated as a single string.
    """
    pattern = r"```yaml\n(.*?)```"
    matches = re.findall(pattern, rsp, re.DOTALL)
    return "\n\n".join(m.strip() for m in matches)


def save_to_yaml(content, workflow_file="build-test-generated.yaml"):
    with open(workflow_file, "w", encoding="utf-8") as f:
        f.write(extract_yaml_as_string(str(content)))
    return content

def read_jenkins_pipeline(pipline):
    try:
        with open(pipline, "r") as f:
            return f.read()
    except FileNotFoundError:
        print(f"Error: File '{pipline}' not found.")
    except Exception as e:
        print(f"Error: {e}")

def main():
    parser = argparse.ArgumentParser(description="Generate GitHub Action from ")
    parser.add_argument("pipeline", type=Path, help="Pipeline to translate")
    parser.add_argument("workflow", type=str, help="Resulting workflow name")
    args = parser.parse_args()
    workflow_name = args.workflow

    pipeline_content = read_jenkins_pipeline(args.pipeline)
    
    #set_debug(True)
    qdrant_client = QdrantClient(host="80.188.223.202", port=10401)
    embeddings = OpenAIEmbeddings(
        base_url="http://80.188.223.202:10433/openai/v1",
        model="qwen3",
        api_key="aaa"
        )

    pipelineContextPrompt = f"Jenkins pipeline is: {pipeline_content.strip()} translate it to GitHub Action workflow using reusable actions"

    results = qdrant_client.query_points(
        collection_name="github_actions_version",
        query= embeddings.embed_query("Github action for: {pipelineContextPrompt}"),
        limit=10
    )
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
    Additinal notes should be provided as workflow comments.
    Name resulting worflow as {workflow}
    """
    
    prompt = PromptTemplate.from_template(
        prompt_template)

    translator_model = ChatOpenAI(
        base_url="http://80.188.223.202:10434/v1",
        model="/mnt/models/gptoss",
        api_key="aaa",
        temperature=0.2
    )

    write_to_file = RunnableLambda(lambda x: save_to_yaml(x))

    github_actions_chain = prompt | translator_model | StrOutputParser() | write_to_file
    response = github_actions_chain.invoke({"pipelineContextPrompt": pipelineContextPrompt, "context": context, "workflow": workflow_name})
    print(response)
    

if __name__ == "__main__":
    main()