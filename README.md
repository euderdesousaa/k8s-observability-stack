# K8s Observability Stack

Este repositório contém uma solução completa de observabilidade para clusters Kubernetes locais utilizando **KinD**. O projeto automatiza a coleta de métricas, centralização de logs e configuração de alertas críticos de infraestrutura.

## Visão Geral

A stack foi projetada para ambientes de recursos limitados (como servidores notebook), utilizando uma arquitetura **Single Binary** para o Loki e limites de recursos otimizados para o Prometheus.

### Tecnologias Utilizadas

* **KinD (Kubernetes in Docker)**: Orquestração do cluster local.
* **Prometheus & Alertmanager**: Coleta de métricas e lógica de alertas.
* **Grafana**: Visualização de dados com dashboards pré-configurados.
* **Loki (Single Binary)**: Agregação de logs de alta performance com baixo consumo de recursos.
* **Promtail**: Coleta e envio de logs dos nós para o Loki.

---

## Estrutura do Projeto

O repositório está organizado para separar as configurações de infraestrutura (Helm) dos manifestos de aplicação (K8s):

```text
k8s-observability-stack/
├── dashboard/             # Dashboards do Grafana exportados (JSON)
├── helm/                  # Configurações de valores (values.yaml) para Helm
│   ├── loki-stack/        # Configuração Loki Single Binary
│   ├── prometheus-stack/  # Overrides para Kube-Prometheus-Stack
│   └── promtail/          # Configurações de coleta de logs
├── k8s/                   # Manifestos Kubernetes puros
│   ├── PrometheusRule.yaml# Regras de alerta customizadas
│   ├── kind-config.yaml   # Mapeamento de portas e nós do KinD
│   ├── namespaces.yaml    # Isolamento lógico (monitoring/logging)
|   ├── test/              # Ferramentas para validação de gatilhos de alerta
│       ├── memory-stress.yaml  
|       └── force-usage.yaml     
└── scripts/               # Scripts de automação
    └── setup-cluster.sh   # Script principal de implantação

```

---

## Instalação e Uso

Para implantar toda a infraestrutura, incluindo a criação do cluster e os componentes de observabilidade, execute o script de configuração:

```bash
chmod +x scripts/setup-cluster.sh
./scripts/setup-cluster.sh

```

O script realiza as seguintes etapas:

1. Cria o cluster KinD com mapeamento de rede customizado.
2. Provisiona os namespaces `monitoring` e `logging`.
3. Instala o Prometheus Stack com limite de memória de **1Gi** e Grafana acessível via **NodePort 32101**.
4. Configura o Loki em modo **Single Binary** para eficiência em hardware local.
5. Aplica as regras de alerta de infraestrutura.

---

## Alertas de Infraestrutura

O sistema inclui **PrometheusRules** configuradas para monitorar estados críticos:

* **NodeMemoryCritical**: Dispara quando a memória disponível é inferior a 10% por 5 minutos. A lógica utiliza a fórmula:


* **NodeHighCPUUsage**: Alerta se o uso de CPU for superior a 90% por mais de 5 minutos.
* **PodsInErrorState**: Detecta containers em estados de erro como `ImagePullBackOff` ou `CrashLoopBackOff`.

---

## Centralização de Logs

Os logs são gerenciados pelo **Loki**. Diferente de instalações complexas em microserviços, esta stack utiliza `deploymentMode: SingleBinary`, o que simplifica a operação em um único pod sem perder capacidades de consulta no Grafana.

## Visualização (Dashboards)

O Grafana pode ser acessado em `http://localhost:32101`. O dashboard incluído na pasta `dashboard/` fornece visibilidade sobre:

* Consumo de CPU por Namespace.
* Utilização de memória em tempo real (`working_set_bytes`).
* Taxa de transferência de rede (Upload/Download).
* Contagem de erros críticos em Pods.
