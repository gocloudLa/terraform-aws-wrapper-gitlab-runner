/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* Gitlab | Variable Definition                                         */
/*----------------------------------------------------------------------*/
variable "gitlab_runner_parameters" {
  type        = any
  description = "gitlab-runner parameteres to configure gitlab-runner module"
  default     = {}
}
