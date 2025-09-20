import argparse
import json
from pathlib import Path
import hashlib
import base64
from langchain_openai import OpenAIEmbeddings
from qdrant_client import QdrantClient

from qdrant_client.models import VectorParams, Distance


def to_entry(s : str) -> tuple[str, str]:

    if not s.startswith("##"):
        return None
    
    cleaned = s.replace("##", "", 1)

    if ":" not in cleaned:
      return None
    
    key, value = cleaned.split(":", 1)
    return key, value
    

def load_documents(folder: Path):
    return [
        {
            "id": hashlib.md5(content.encode("utf-8")).hexdigest(),
            "payload": {"file": file.name, "content": content} | dict(filter(None, (map(to_entry, content.splitlines()))))
         }
        for file in folder.glob("*.yaml")
        if (content := file.read_text(encoding="utf-8").strip())
    ]

def main():
    parser = argparse.ArgumentParser(description="Load text files into documents list")
    parser.add_argument("folder", type=Path, help="Path to the folder")

    args = parser.parse_args()
    documents = load_documents(args.folder)

    embeddings = OpenAIEmbeddings(
        base_url="http://80.188.223.202:10433/openai/v1",
        model="qwen3",
        api_key="aaa"
        )
    
    for doc in documents:
        doc['vector'] = embeddings.embed_documents([doc['payload']['content']])[0]
        print(f"{doc['payload']['file']} -> {len(doc['payload']['content'].split())} words | {doc['payload']} | {len(doc['vector'])} embeddings")

    qdrant_client = QdrantClient(host="80.188.223.202", port=10401)

    if not qdrant_client.collection_exists("github_actions_version"):
        qdrant_client.create_collection(
            collection_name="github_actions_version",
            vectors_config=VectorParams(size=4096, distance=Distance.COSINE),
        )
      
    qdrant_client.upsert (
        collection_name ="github_actions_version",
        points = documents
    )


if __name__ == "__main__":
    main()
