# Step 1: Package dependencies (only rebuilds when pyproject.toml changes)
resource "null_resource" "package_dependencies" {
  triggers = {
    dependencies_hash = local.dependencies_hash
    python_runtime    = var.python_runtime
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      export SOURCE_PATH="${var.runtime_source_path}"
      export OUTPUT_DIR="${local.package_output_dir}"
      export PYTHON_VERSION="${lower(replace(replace(var.python_runtime, "PYTHON_", ""), "_", "."))}"

      ${path.module}/scripts/install_dependencies.sh
    EOT
  }
}

# Step 2: Package code (rebuilds when code changes, uses cached dependencies)
resource "null_resource" "package_code" {
  triggers = {
    code_hash              = local.code_files_hash
    dependencies_hash      = local.dependencies_hash
    agent_name             = var.agent_name
    entry_file             = var.entry_file
    additional_source_dirs = join(",", var.additional_source_dirs)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      export SOURCE_PATH="${var.runtime_source_path}"
      export OUTPUT_DIR="${local.package_output_dir}"
      export ENTRY_FILE="${var.entry_file}"
      export ADDITIONAL_DIRS="${join(" ", var.additional_source_dirs)}"

      ${path.module}/scripts/package_code.sh
    EOT
  }

  depends_on = [null_resource.package_dependencies]
}
