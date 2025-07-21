resource "local_file" "curl_prompt_script_kserve" {
  for_each = var.prompt
  filename        = "curl-${var.model}-${each.key}.sh"
  file_permission = "0755"

  content = <<-EOT
    #!/bin/bash

    HOST_IP="${var.host_ip}"
    PORT="${var.inference_port}"

    read -r -d '' PAYLOAD <<EOF
    {
        "prompt": "${replace(each.value, "\n", "\\n")}",
        "model": "${var.model}",
        "stream": false,
        "max_tokens": ${var.max_tokens}
    }
    EOF

    curl -v -s -X POST "$HOST_IP:$PORT/openai/v1/completions" -H "Content-Type: application/json" -d "$PAYLOAD" && echo

  EOT
}
