from huggingface_hub import snapshot_download
import sys

# Replace with your model namea
target_model = sys.argv[1]
model_name = sys.argv[2]

# Download to specific folder (e.g., your PVC mount or hostPath)
snapshot_download(
    repo_id=target_model,
    local_dir="/home/user/models/" + model_name,
    allow_patterns=[
        "config.json",
        "generation_config.json",
        "tokenizer.json",
        "tokenizer_config.json",
        "*.safetensors",
        "tokenizer.model",
        "vocab.*"
    ],
    ignore_patterns=["*adapter*", "*lora*", "*.onnx", "*.ckpt"]
)
