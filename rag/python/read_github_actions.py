import argparse
import json
from pathlib import Path
import hashlib
import base64
from langchain_openai import OpenAIEmbeddings
from qdrant_client import QdrantClient
from langchain_qdrant import QdrantVectorStore


def to_entry(s : str) -> tuple[str, str]:

    if not s.startswith("##"):
        return None
    
    cleaned = s.replace("##", "", 1)

    if ":" not in cleaned:
      return None
    
    key, value = cleaned.split(":", 1)
    return key, value

def read_labels (file_content: str): 
    lables = {}
    for line in str.splitlines(): 
        if line.startswith("##"): 
            line = line.replace("##", "", 1)
            kv = line.split(":")
            lables[kv[0]] = kv[1]
    

def load_documents(folder: Path):
    return [
        {
            "id": hashlib.md5(content.encode("utf-8")).hexdigest(),
            "file": file.name, 
            "content": content, 
            "labels": json.dumps(dict(filter(None, (map(to_entry, content.splitlines()))))) 
         }
        for file in folder.glob("*.yaml")
        if (content := file.read_text(encoding="utf-8").strip())
    ]

def main():
    parser = argparse.ArgumentParser(description="Load text files into documents list")
    parser.add_argument("folder", type=Path, help="Path to the folder")

    args = parser.parse_args()
    documents = load_documents(args.folder)

    for doc in documents:
        print(f"{doc['file']} -> {len(doc['content'].split())} words | {doc['labels']} meta")

    embeddings = OpenAIEmbeddings(
        base_url="http://80.188.223.202:10433/v1",
        model="qwen3",
        api_key="aaa"
        )
    qdrant_client = QdrantClient(host="80.188.223.202", port=10401, prefer_grpc=True)

    vectorstore = QdrantVectorStore(
        client=qdrant_client,
        collection_name="github_actions_version",
        embedding=embeddings
    )

    if documents:
        vectorstore.add_documents(documents)
        print(f"✅ Inserted {len(documents)} docs into Qdrant")

if __name__ == "__main__":
    main()
