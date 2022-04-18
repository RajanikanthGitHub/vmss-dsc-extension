variable "dsc_config" {
  type    = string
  default = "MMAgent"
}

variable "dsc_module_path" {
  type    = string
  default = "https://rajanikanthsa.blob.core.windows.net/vmss-sa-container/MMAgent.zip"
}

variable "dsc_config_mode" {
  type = string
  default = "ApplyandAutoCorrect"
}