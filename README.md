# Infraestrutura como código: preparando máquinas na AWS com Ansible e Terraform

Ferramentas utilizadas: Terraform e ansible, com aws

Criar, gerenciar e controlar sua infraestrutura em ambiente de produção através de código.

## **Instalar ferramentas**

### **Terraform**

Caso você ainda não tenha instalado o Terraform, segue um pequeno tutorial de como fazê-lo.

#### **Ubuntu**

Para instalar no Ubuntu, utilize o comando abaixo:

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install terraform
 ```

## **Ansible**

Caso você ainda não tenha instalado o Ansible, segue um pequeno tutorial de como fazê-lo.

## **Instalando Ansible**

### **Ubuntu**

Para instalar no Ubuntu, utilize o comando abaixo:

``` 
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible
```

## **AWS CLI**

Caso você ainda não tenha instalado a AWS CLI, basta ir a [página da AWS CLI](https://docs.aws.amazon.com/pt_br/cli/latest/userguide/install-cliv2.html) e seguir os procedimentos para o seu sistema operacional.

Depois de instalado você pode configurar a AWS usando o comando `aws configure` onde será requisitado a chave secreta (secret key) que pode ser criada [nessa pagina](https://console.aws.amazon.com/iam/home?#/security_credentials) clicando em “criar chave de acesso” na aba “credenciais do AWS IAM”.

## **Iniciando com Terraform**

- Baixar modulos do terraform para se comunicar com a AWS, executar o comando dentro da pasta em que está o main.tf

```bash
terraform init
```

- Executar comando de planejamento, onde traz todas as informações sobre a instância que gostaríamos de criar

```bash
terraform plan
```

- Criar a maquina na AWS

```bash
terraform apply
```

## **Utilizando o ansible**

- Após gerar [par de chave ssh](https://docs.aws.amazon.com/pt_br/AWSEC2/latest/UserGuide/ec2-key-pairs.html) na aws podemos dar continuidade utilizando o ansible

- Devemos criar 2 arquivos essenciais para o ansible funcionar

chamados de `host.yml` e `playbook.yml`

- Preparando ambiente python (django) na instância

```bash
# hosts.yml

[terraform-ansible]
54.185.82.48    # ipv4 público da instâcia da qual vamos gerenciar 
```

```bash
# playbook.yml

# code: language=ansible
- hosts: terraform-ansible
  tasks:
    - name: Instalando python3 e virtualenv
      apt:                                                # Instalação do python3 e virtualenv
        pkg:                                              # Pacotes a serem instalados
        - python3                                         # Python3
        - virtualenv                                      # Virtualenv
        update_cache: yes                                 # Atualiza o cache do apt
      become: yes                                         # become: yes é para executar como root
    - name: Intalando dependencias com pip (Django e Django Rest) em uma virtualenv
      pip:                                                # Instalação do Django e Django Rest
        virtualenv: /home/ubuntu/myproject/venv           # Caminho do virtualenv
        name:                                             # Pacotes a serem instalados
          - django                                        # Django
          - djangorestframework                           # Django Rest
    - name: Criando projeto Django
      shell: '. /home/ubuntu/myproject/venv/bin/activate; django-admin startproject setup /home/ubuntu/myproject'
      ignore_errors: yes
    - name: Alterando o hosts do settings.py
      lineinfile:
        path: /home/ubuntu/myproject/setup/settings.py    # Caminho do settings.py
        regexp: 'ALLOWED_HOSTS = \[\]'                    # Expressão regular para encontrar a linha
        line: 'ALLOWED_HOSTS = ["*"]'                     # Linha a ser inserida
        backrefs: yes                                     # Se não encontrar a linha, não faz nada
```

- Rodar o comando ansible para gerenciar a instância : ansible-playbook <playbook que quisermos executar> -u <usuário da máquina na aws> --private-key <file chave ssh> -i <arquivo de hosts.yml>

```bash
ansible-playbook playbook.yml -u ubuntu --private-key Infra-oregon.pem -i hosts.yml
```

