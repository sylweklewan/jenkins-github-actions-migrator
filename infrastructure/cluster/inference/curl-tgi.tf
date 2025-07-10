resource "local_file" "curl_prompt_script_tgi" {
  filename        = "curl-tgi-${var.model}.sh"
  file_permission = "0755"

  content = <<-EOT
    #!/bin/bash


    HOST_IP="${var.host_ip}"
    PORT="${var.inference_port}"
    MODEL="${var.model}"
    PROMPT='${var.prompt}'

    read -r -d '' PAYLOAD <<EOF
    {
      "inputs": $PROMPT
    }
    EOF

    curl -v -s -X POST "$HOST_IP:$PORT/generate" -H "Content-Type: application/json" -d "$PAYLOAD" && echo

  EOT
}
