resource "local_file" "curl_prompt_script" {
  filename        = "curl-${var.model}.sh"
  file_permission = "0755"

  content = <<-EOT
    #!/bin/bash

    HOST_IP="${var.host_ip}"
    PORT="${var.inference_port}"
    MODEL="${var.model}"
    PROMPT='${var.prompt}'

    read -r -d '' PAYLOAD <<EOF
    {
      "instances": $PROMPT
    }
    EOF

    curl -s -X POST "$HOST_IP:$PORT/v1/models/$MODEL:predict" -H "Content-Type: application/json" -d "$PAYLOAD" && echo

  EOT
}
