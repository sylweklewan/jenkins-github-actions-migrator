import argparse
import re
from pathlib import Path
from langchain_openai import ChatOpenAI

from langchain.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnableLambda


def extract_yaml_as_string(rsp):
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
    



    #Prompt catalogue https://smith.langchain.com/hub/langchain-ai/retrieval-qa-chat
    prompt_template = """SYSTEM: You are an expert GitHub CI/CD engineer. 
    Translate jenkins pipeline {pipeline} to GitHub Actions workflow. 
    
    Requirements:
    Use latest versions of standard actions.
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
    response = github_actions_chain.invoke({"pipeline": pipeline_content, "workflow": workflow_name})
    print(response)
    
if __name__ == "__main__":
    main()