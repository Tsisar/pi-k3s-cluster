# Canary Rollout з Argo CD та Helm

Цей чарт використовує Argo Rollouts для безпечного розгортання нових версій через стратегію Canary.

## Основні можливості

- Поступове оновлення версій із контролем трафіку
- Інтеграція з NGINX Ingress
- Підтримка ручного або автоматичного просування через `steps`

## Як задеплоїти

### 1. Встановлення через Helm

```bash
helm upgrade --install my-app ./chart \
  --namespace default \
  --set image.repository=gcr.io/your-project/app \
  --set image.tag=v2.0.0
```

### 2. Синхронізація через Argo CD

Додай репозиторій, шлях до чарту та натисни Sync.

## Налаштування

### values.yaml

```yaml
image:
  repository: gcr.io/your-project/app
  tag: v2.0.0

replicaCount: 4

ingress:
  host: app.example.com

rollout:
  canary:
    steps:
      - weight: 25
        pause: true
      - weight: 50
        pause: true
      - weight: 100
        pause: false
```

## Керування rollout

Перевірити статус:

```bash
kubectl argo rollouts get rollout my-app-rollout
```

Просунути до наступного step:

```bash
kubectl argo rollouts promote my-app-rollout
```

Відкотити:

```bash
kubectl argo rollouts abort my-app-rollout
```

## Canary трафік

Rollout керує трафіком через NGINX Ingress:

- `my-app-stable` — стабільна версія
- `my-app-canary` — отримує частку трафіку

Приклад Ingress:

```yaml
spec:
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app-stable
                port:
                  name: http
```

## Залежності

- Argo CD
- Argo Rollouts Controller
- NGINX Ingress Controller (з підтримкою canary routing)

## Моніторинг

Рекомендується додати перевірки через UptimeRobot або Prometheus (ключове слово або HTTP статус).