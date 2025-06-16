# Raspberry Pi Monitoring Setup (Telegraf + InfluxDB)

Ця інструкція дозволяє підключити Raspberry Pi до централізованого моніторингу на базі InfluxDB через Telegraf.

---

## 1. Встановлюємо Telegraf

Додаємо офіційний репозиторій InfluxData:

```bash
wget -qO- https://repos.influxdata.com/influxdata-archive_compat.key | sudo tee /etc/apt/keyrings/influxdata-archive_compat.key > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/influxdata-archive_compat.key] https://repos.influxdata.com/debian stable main" | sudo tee /etc/apt/sources.list.d/influxdata.list
```

Після цього встановлюємо Telegraf:

```bash
sudo apt-get update
sudo apt install telegraf
```

---

## 2. Налаштовуємо Telegraf

Редагуємо конфігурацію:

```bash
sudo nano /etc/telegraf/telegraf.conf
```

Вставляємо наступний конфіг:

```toml
###############################################################################
# OUTPUT PLUGIN
###############################################################################

[[outputs.influxdb]]
urls = ["http://192.168.88.30:8086"]
database = "mydb"
username = "admin"
password = "admin"

###############################################################################
# AGENT SETTINGS
###############################################################################

[agent]
interval = "10s"
round_interval = true
metric_batch_size = 1000
metric_buffer_limit = 10000
collection_jitter = "0s"
flush_interval = "10s"
flush_jitter = "0s"
precision = ""
hostname = ""
omit_hostname = false

###############################################################################
# INPUT PLUGINS
###############################################################################

# CPU usage
[[inputs.cpu]]
percpu = true
totalcpu = true
collect_cpu_time = false
report_active = false

# Memory usage
[[inputs.mem]]

# Disk usage
[[inputs.disk]]
ignore_fs = ["tmpfs", "devtmpfs", "devfs"]

# Disk I/O
[[inputs.diskio]]

# Network usage
[[inputs.net]]
interfaces = ["eth0", "wlan0"]

# System stats
[[inputs.system]]

# Swap usage
[[inputs.swap]]

# Netstat protocol stats
[[inputs.netstat]]

# Processes
[[inputs.processes]]

# Kernel stats
[[inputs.kernel]]

# CPU temperature (main CPU temp sensor)
[[inputs.file]]
files = ["/sys/class/thermal/thermal_zone0/temp"]
name_override = "cpu_temperature"
data_format = "value"
data_type = "integer"

# GPU temperature (via vcgencmd)
[[inputs.exec]]
commands = ["/usr/bin/vcgencmd measure_temp"]
name_override = "gpu_temperature"
data_format = "grok"
grok_patterns = ["temp=%{NUMBER:value:float}'C"]

###############################################################################
# GLOBAL TAGS
###############################################################################

[global_tags]
host = "raspberry-pi"
```

**УВАГА:**
Для кожної ноди бажано встановлювати унікальний `host` тег:

```toml
[global_tags]
host = "pi-node-01"
```

щоб у кластерному моніторингу можна було розрізняти ноди.

---

## 3. Додаємо доступ до відео-групи (для GPU температури)

```bash
sudo usermod -aG video telegraf
sudo systemctl restart telegraf
```

---

## 4. Перевіряємо роботу

Запускаємо перевірку:

```bash
sudo telegraf --config /etc/telegraf/telegraf.conf --test
```

> Має бути видно усі зібрані метрики без помилок.

---

## Після виконання цього інструктажу

* Raspberry Pi підключений до центрального InfluxDB.
* Дані збираються через Telegraf.
* Можна підключати в Grafana.
