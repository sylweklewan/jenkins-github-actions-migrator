resource "local_file" "curl_embeddings_sanity" {
  filename        = "curl-embeddings-${var.embedding_model}-sanity.sh"
  file_permission = "0755"

  content = <<-EOT
    #!/bin/bash

    HOST_IP="${var.host_ip}"
    PORT="${var.embedding_port}"

    read -r -d '' PAYLOAD <<EOF
    {
        "input": "This is an example sentence for embedding generation.",
        "model": "${var.embedding_model}"
    }
    EOF

    curl -v -s -X POST "$HOST_IP:$PORT/openai/v1/embeddings" -H "Content-Type: application/json" -d "$PAYLOAD" && echo

  EOT
}