source <(k3s completion bash)
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k