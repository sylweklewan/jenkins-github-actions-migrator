resource "local_file" "curl_translate_jenkins" {
  for_each        = var.jenkins_pipeline_files
  filename        = "curl-jenkins-${var.model}-${each.key}.sh"
  file_permission = "0755"

  content = <<-EOT
    #!/bin/bash

    HOST_IP="${var.host_ip}"
    PORT="${var.inference_port}"

    read -r -d '' PAYLOAD <<EOF
    {
        "prompt": "${var.jenkins_pipeline_prompt_start}\\n${replace(file(each.value), "\n", "\\n")}",
        "model": "/mnt/models/${var.model}",
        "stream": false,
        "max_tokens": ${var.max_tokens}
    }
    EOF

    curl -v -s -X POST "$HOST_IP:$PORT/v1/completions" -H "Content-Type: application/json" -d "$PAYLOAD" && echo

  EOT
}