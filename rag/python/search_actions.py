from langchain_qdrant import QdrantVectorStore
from langchain_openai import OpenAIEmbeddings
from langchain_openai import ChatOpenAI
from qdrant_client import QdrantClient, models

from langchain.prompts import PromptTemplate
from langchain.chains.retrieval import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain.globals import set_debug


# def format_docs(docs):
#     return "\n\n".join(doc.page_content for doc in docs)
#     #print(docs)
#     #return "\n".join(r.payload['document'] for r in docs.points)

def format_docs(docs):
    context = "\n".join(d.payload["content"] for d in docs.points)
    

def main():

    set_debug(True)
    qdrant_client = QdrantClient(host="80.188.223.202", port=10401)
      
    embeddings = OpenAIEmbeddings(
        base_url="http://80.188.223.202:10433/openai/v1",
        model="qwen3",
        api_key="aaa"
        )

    vectorstore = QdrantVectorStore(
        client=qdrant_client,
        collection_name="github_actions_version",
        embedding=embeddings
    )

    # qdrant = Qdrant(
    #     url="http://80.188.223.202:10401",
    #     collection_name="github_actions_version",
    #     embedding=embeddings
    # )

    # See full prompt at https://smith.langchain.com/hub/langchain-ai/retrieval-qa-chat

    #retrieval_qa_chat_prompt = hub.pull("langchain-ai/retrieval-qa-chat")
    #https://smith.langchain.com/hub/devopsclient/new_crafted_prompt


    jenkins_pipeline = """
pipeline {
    agent { docker { image 'golang:1.25.0-alpine3.22' } }
    stages {
        stage('get version') {
            steps {
                sh 'go version'
            }
        }
    }
}
"""

    maven_pipeline = """
pipeline {
    agent { docker { image 'maven:3.9.11-eclipse-temurin-21-alpine' } }
    stages {
        stage('build') {
            steps {
                sh 'mvn --version'
            }
        }
    }
}
"""

    pipelineContextPrompt = f"Jenkins pipeline is: {jenkins_pipeline.strip()} translate it to GitHub Action workflow"
    print(pipelineContextPrompt)


    results = qdrant_client.query_points(
        collection_name="github_actions_version",
        query= embeddings.embed_query("Github action for: {pipelineContextPrompt}"),
        limit=2
    )
    print([{ "payload": p.payload, "score": p.score} for p in results.points])
    context = "\n######################".join([p.payload['content'].strip() for p in results.points])


    prompt_template = """SYSTEM: You are an expert GitHub CI/CD engineer. 
    I will provide you with a Jenkinsfile that defines a CI/CD pipeline. 
    {pipelineContextPrompt} using context: {context}

    Requirements:
    Be factual in your response. 
    Use most suitable GitHub action from context.
    
    If you cannot find a match, say you don't know. Just provide one single workflow that matches best
    """
    #
    prompt = PromptTemplate.from_template(
        prompt_template)

    translator_model = ChatOpenAI(
        base_url="http://80.188.223.202:10434/openai/v1",
        model="deepseek",
        api_key="aaa"
    )


    # github_actions_chain = (
    #     { "context": format_docs(results), "pipelineContextPrompt": RunnablePassthrough() }
    #     | prompt
    #     | translator_model
    #     | StrOutputParser()
    # )


    #chain = prompt | llm | output_parser

    

    # transaltor_chain = create_stuff_documents_chain(translator_model, prompt)
    # rag_chain = create_retrieval_chain(vectorstore.as_retriever(), transaltor_chain)
    # rag_chain.invoke({"pipeline": "go version"})


    #chain.invoke({"topic":"movies","question":"Tell me about The Godfather movie"})
    github_actions_chain = prompt | translator_model | StrOutputParser()
    response = github_actions_chain.invoke({"pipelineContextPrompt": pipelineContextPrompt, "context": context})
    
    # print(response)


    # results = qdrant_client.query_points(
    #     collection_name="github_actions_version",
    #     query= embeddings.embed_query("Github action for: {maven_pipeline}"),
    #     limit=3,
    #     with_vectors=True
    # )
    # print([{ "payload": p.payload, "score": p.score} for p in results.points])

if __name__ == "__main__":
    main()

