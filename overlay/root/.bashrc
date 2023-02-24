source <(k3s completion bash)
source <(kubectl completion bash | sed 's#"${requestComp}" 2>/dev/null#"${requestComp}" 2>/dev/null | head -n -1 | fzf  --multi=0 #g')
alias k=kubectl
complete -o default -F __start_kubectl k