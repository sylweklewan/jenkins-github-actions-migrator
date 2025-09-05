from langchain_qdrant import QdrantVectorStore
from langchain_openai import OpenAIEmbeddings
from langchain_openai import ChatOpenAI
from qdrant_client import QdrantClient

from langchain.prompts import PromptTemplate
from langchain.chains.retrieval import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

def main():

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

    # See full prompt at https://smith.langchain.com/hub/langchain-ai/retrieval-qa-chat

    #retrieval_qa_chat_prompt = hub.pull("langchain-ai/retrieval-qa-chat")
    #https://smith.langchain.com/hub/devopsclient/new_crafted_prompt
    prompt_template = """SYSTEM: You are an expert GitHub CI/CD engineer. 
    I will provide you with a Jenkinsfile that defines a CI/CD pipeline. 
    Try to find similar github action in {context} and use it as context
    Jenkins pipeline is: {pipeline}

    Requirements:
    Be factual in your response. 
    
    If you cannot find a match, say you don't know.
    """
    #
    prompt = PromptTemplate.from_template(prompt_template)

    translator_model = ChatOpenAI(
        base_url="http://80.188.223.202:10434/openai/v1",
        model="deepseek",
        api_key="aaa"
    )

    # transaltor_chain = create_stuff_documents_chain(translator_model, prompt)
    # rag_chain = create_retrieval_chain(vectorstore.as_retriever(), transaltor_chain)
    # rag_chain.invoke({"pipeline": "go version"})


    qa_chain = (
        {
            "context": vectorstore.as_retriever() | format_docs,
            "pipeline": RunnablePassthrough(),
        }
        | prompt
        | translator_model
        | StrOutputParser()
    )

    response = qa_chain.invoke("""
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
""")
    
    print(response)

if __name__ == "__main__":
    main()

